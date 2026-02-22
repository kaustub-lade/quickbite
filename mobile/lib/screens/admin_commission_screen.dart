import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class AdminCommissionScreen extends StatefulWidget {
  const AdminCommissionScreen({Key? key}) : super(key: key);

  @override
  State<AdminCommissionScreen> createState() => _AdminCommissionScreenState();
}

class _AdminCommissionScreenState extends State<AdminCommissionScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _commissionData;
  DateTimeRange? _dateRange;
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadCommissionData();
  }

  Future<void> _loadCommissionData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        setState(() {
          _error = 'Authentication required';
          _isLoading = false;
        });
        return;
      }

      final data = await apiService.getCommissionReports(
        token: token,
        startDate: _dateRange?.start,
        endDate: _dateRange?.end,
        status: _statusFilter == 'all' ? null : _statusFilter,
      );

      setState(() {
        _commissionData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateCommissionStatus(String orderId, String type, String status) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) return;

      await apiService.updateCommissionStatus(
        token: token,
        orderId: orderId,
        type: type,
        status: status,
      );

      // Reload data
      _loadCommissionData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $status')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  Future<void> _selectDateRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (pickedRange != null) {
      setState(() {
        _dateRange = pickedRange;
      });
      _loadCommissionData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commission & Payouts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCommissionData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCommissionData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCommissionData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilters(),
                        const SizedBox(height: 24),
                        _buildSummaryCards(),
                        const SizedBox(height: 24),
                        _buildByRestaurantSection(),
                        const SizedBox(height: 24),
                        _buildByDateSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _dateRange == null
                          ? 'Select Date Range'
                          : '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                if (_dateRange != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _dateRange = null;
                      });
                      _loadCommissionData();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _statusFilter,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'paid', child: Text('Paid')),
                DropdownMenuItem(value: 'refunded', child: Text('Refunded')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _statusFilter = value;
                  });
                  _loadCommissionData();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final summary = _commissionData?['summary'];
    if (summary == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildSummaryCard(
              'Total Orders',
              summary['totalOrders'].toString(),
              Icons.receipt_long,
              Colors.blue,
            ),
            _buildSummaryCard(
              'Total Revenue',
              '₹${_formatNumber(summary['totalRevenue'])}',
              Icons.attach_money,
              Colors.green,
            ),
            _buildSummaryCard(
              'Total Commission',
              '₹${_formatNumber(summary['totalCommission'])}',
              Icons.account_balance_wallet,
              Colors.orange,
            ),
            _buildSummaryCard(
              'Restaurant Payout',
              '₹${_formatNumber(summary['totalRestaurantPayout'])}',
              Icons.store,
              Colors.purple,
            ),
            _buildSummaryCard(
              'Pending Commission',
              '₹${_formatNumber(summary['pendingCommission'])}',
              Icons.hourglass_empty,
              Colors.amber,
            ),
            _buildSummaryCard(
              'Paid Commission',
              '₹${_formatNumber(summary['paidCommission'])}',
              Icons.check_circle,
              Colors.teal,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildByRestaurantSection() {
    final byRestaurant = _commissionData?['byRestaurant'] as List?;
    if (byRestaurant == null || byRestaurant.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'By Restaurant',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: byRestaurant.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final restaurant = byRestaurant[index];
              return ListTile(
                title: Text(restaurant['restaurantName'] ?? 'Unknown'),
                subtitle: Text(
                  '${restaurant['orderCount']} orders • Revenue: ₹${_formatNumber(restaurant['totalRevenue'])}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${_formatNumber(restaurant['commissionEarned'])}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      'Pending: ₹${_formatNumber(restaurant['pendingPayout'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildByDateSection() {
    final byDate = _commissionData?['byDate'] as List?;
    if (byDate == null || byDate.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Breakdown',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: byDate.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final day = byDate[index];
              final date = DateTime.parse(day['_id']);
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${day['orderCount']}'),
                ),
                title: Text(DateFormat('EEEE, MMM d').format(date)),
                subtitle: Text('Revenue: ₹${_formatNumber(day['totalRevenue'])}'),
                trailing: Text(
                  '₹${_formatNumber(day['totalCommission'])}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    if (number is int) return number.toString();
    if (number is double) return number.toStringAsFixed(2);
    return number.toString();
  }
}
