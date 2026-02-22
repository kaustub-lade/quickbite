import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String token;

  const AdminDashboardScreen({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Order trends data
  List<dynamic> _orderTrends = [];
  double _totalRevenue = 0;
  int _totalOrders = 0;
  double _avgOrderValue = 0;
  double _completionRate = 0;
  
  // Popular items data
  List<dynamic> _popularItems = [];
  List<dynamic> _categoryDistribution = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      
      // Load order trends and popular items in parallel
      final results = await Future.wait([
        apiService.getOrderTrends(days: 30, groupBy: 'day', token: widget.token),
        apiService.getPopularItems(limit: 10, days: 30, token: widget.token),
      ]);

      final trendsData = results[0] as Map<String, dynamic>;
      final itemsData = results[1] as Map<String, dynamic>;

      setState(() {
        _orderTrends = trendsData['trends'] ?? [];
        _popularItems = itemsData['items'] ?? [];
        _categoryDistribution = itemsData['categoryDistribution'] ?? [];
        
        // Calculate summary statistics
        _totalRevenue = 0;
        _totalOrders = 0;
        double totalCompletion = 0;
        
        for (var trend in _orderTrends) {
          _totalRevenue += (trend['totalRevenue'] ?? 0).toDouble();
          _totalOrders += (trend['totalOrders'] ?? 0) as int;
          totalCompletion += (trend['completionRate'] ?? 0).toDouble();
        }
        
        _avgOrderValue = _totalOrders > 0 ? _totalRevenue / _totalOrders : 0;
        _completionRate = _orderTrends.isNotEmpty ? totalCompletion / _orderTrends.length : 0;
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFFEA580C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDashboardData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Cards
                        _buildSummaryCards(),
                        const SizedBox(height: 24),
                        
                        // Order Trends Section
                        _buildSectionTitle('Order Trends (Last 30 Days)'),
                        const SizedBox(height: 12),
                        _buildOrderTrendsList(),
                        const SizedBox(height: 24),
                        
                        // Popular Items Section
                        _buildSectionTitle('Top 10 Popular Items'),
                        const SizedBox(height: 12),
                        _buildPopularItemsList(),
                        const SizedBox(height: 24),
                        
                        // Category Distribution Section
                        if (_categoryDistribution.isNotEmpty) ...[
                          _buildSectionTitle('Category Distribution'),
                          const SizedBox(height: 12),
                          _buildCategoryDistribution(),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Revenue',
            value: '₹${_totalRevenue.toStringAsFixed(0)}',
            icon: Icons.currency_rupee,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Orders',
            value: _totalOrders.toString(),
            icon: Icons.shopping_bag,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOrderTrendsList() {
    if (_orderTrends.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No order data available')),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: const [
                Expanded(flex: 2, child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Orders', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(child: Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
              ],
            ),
          ),
          // Rows (show last 7 days)
          ...(_orderTrends.take(7).map((trend) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      _formatDate(trend['date'] ?? ''),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${trend['totalOrders'] ?? 0}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '₹${(trend['totalRevenue'] ?? 0).toStringAsFixed(0)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green),
                    ),
                  ),
                ],
              ),
            );
          }).toList()),
        ],
      ),
    );
  }

  Widget _buildPopularItemsList() {
    if (_popularItems.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No popular items data available')),
        ),
      );
    }

    return Card(
      child: Column(
        children: _popularItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final menuItem = item['menuItem'];
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFEA580C),
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              menuItem?['name'] ?? 'Unknown Item',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${item['totalOrders']} orders • ₹${(item['totalRevenue'] ?? 0).toStringAsFixed(0)} revenue',
            ),
            trailing: Text(
              '₹${menuItem?['price'] ?? 0}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEA580C),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryDistribution() {
    if (_categoryDistribution.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No category data available')),
        ),
      );
    }

    // Calculate total revenue for percentage
    double totalRevenue = 0;
    for (var category in _categoryDistribution) {
      totalRevenue += (category['revenue'] ?? 0).toDouble();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: _categoryDistribution.map<Widget>((category) {
            final categoryName = category['category'] ?? 'Unknown';
            final revenue = (category['revenue'] ?? 0).toDouble();
            final count = category['count'] ?? 0;
            final percentage = totalRevenue > 0 ? (revenue / totalRevenue * 100) : 0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        categoryName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '₹${revenue.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEA580C)),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count items',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
