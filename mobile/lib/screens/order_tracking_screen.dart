import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _trackingData;
  StreamSubscription? _sseSubscription;
  bool _useSSE = true;

  @override
  void initState() {
    super.initState();
    if (_useSSE) {
      _startSSEStream();
    } else {
      _loadTrackingData();
    }
  }

  @override
  void dispose() {
    _sseSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startSSEStream() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        setState(() {
          _error = 'Authentication required';
          _isLoading = false;
        });
        return;
      }

      final apiService = Provider.of<ApiService>(context, listen: false);
      final baseUrl = ApiService.baseUrl;
      
      final uri = Uri.parse('$baseUrl/api/orders/tracking?orderId=${widget.orderId}&stream=true');

      final request = http.Request('GET', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });

        // Listen to SSE stream
        streamedResponse.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
          (String line) {
            if (line.startsWith('data: ')) {
              final jsonStr = line.substring(6); // Remove "data: " prefix
              try {
                final data = json.decode(jsonStr);
                if (data['type'] == 'initial' || data['type'] == 'update') {
                  setState(() {
                    _trackingData = data['tracking'];
                  });
                }
              } catch (e) {
                print('Error parsing SSE data: $e');
              }
            }
          },
          onError: (error) {
            setState(() {
              _error = 'Connection error: $error';
            });
          },
          onDone: () {
            print('SSE stream closed');
          },
          cancelOnError: false,
        );
      } else {
        setState(() {
          _error = 'Failed to connect: ${streamedResponse.statusCode}';
          _isLoading = false;
        });
        
        // Fallback to polling
        _useSSE = false;
        _loadTrackingData();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to start tracking: $e';
        _isLoading = false;
      });
      
      // Fallback to polling
      _useSSE = false;
      _loadTrackingData();
    }
  }

  Future<void> _loadTrackingData() async {
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

      final data = await apiService.getOrderTracking(
        token: token,
        orderId: widget.orderId,
      );

      setState(() {
        _trackingData = data['tracking'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        actions: [
          if (!_useSSE)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadTrackingData,
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
                        onPressed: _loadTrackingData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _trackingData == null
                  ? const Center(child: Text('No tracking data available'))
                  : RefreshIndicator(
                      onRefresh: _loadTrackingData,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatusCard(),
                            const SizedBox(height: 24),
                            _buildETASection(),
                            const SizedBox(height: 24),
                            _buildDeliveryPersonSection(),
                            const SizedBox(height: 24),
                            _buildStatusTimeline(),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildStatusCard() {
    final status = _trackingData?['status'] ?? 'unknown';
    final statusInfo = _getStatusInfo(status);

    return Card(
      elevation: 4,
      color: statusInfo['color'],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(
              statusInfo['icon'],
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusInfo['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusInfo['subtitle'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            if (_useSSE)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.circle,
                  size: 12,
                  color: Colors.greenAccent,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildETASection() {
    final estimatedDeliveryTime = _trackingData?['estimatedDeliveryTime'];
    final etaMinutes = _trackingData?['etaMinutes'];
    
    if (estimatedDeliveryTime == null) {
      return const SizedBox.shrink();
    }

    final eta = DateTime.parse(estimatedDeliveryTime);
    final timeFormat = DateFormat('h:mm a');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 32, color: Colors.orange),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estimated Delivery',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeFormat.format(eta),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  if (etaMinutes != null && etaMinutes > 0)
                    Text(
                      'In approximately $etaMinutes minutes',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryPersonSection() {
    final deliveryPerson = _trackingData?['deliveryPerson'];
    
    if (deliveryPerson == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 32,
              child: Icon(Icons.delivery_dining, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delivery Partner',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deliveryPerson['name'] ?? 'Delivery Partner',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (deliveryPerson['phone'] != null)
                    Text(
                      deliveryPerson['phone'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.green),
              onPressed: () {
                // TODO: Implement call functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Calling delivery partner...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final statusHistory = _trackingData?['statusHistory'] as List?;
    
    if (statusHistory == null || statusHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Timeline',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: statusHistory.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final entry = statusHistory[statusHistory.length - 1 - index];
                final timestamp = DateTime.parse(entry['timestamp']);
                final timeFormat = DateFormat('MMM d, h:mm a');
                final statusInfo = _getStatusInfo(entry['status']);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: statusInfo['color'],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        statusInfo['icon'],
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusInfo['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeFormat.format(timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (entry['note'] != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              entry['note'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'pending':
        return {
          'title': 'Order Placed',
          'subtitle': 'Your order is being prepared',
          'icon': Icons.receipt_long,
          'color': Colors.blue,
        };
      case 'confirmed':
        return {
          'title': 'Order Confirmed',
          'subtitle': 'Restaurant is preparing your food',
          'icon': Icons.check_circle,
          'color': Colors.green,
        };
      case 'preparing':
        return {
          'title': 'Preparing',
          'subtitle': 'Your food is being cooked',
          'icon': Icons.restaurant,
          'color': Colors.orange,
        };
      case 'ready':
        return {
          'title': 'Ready for Pickup',
          'subtitle': 'Waiting for delivery partner',
          'icon': Icons.done_all,
          'color': Colors.teal,
        };
      case 'out_for_delivery':
        return {
          'title': 'Out for Delivery',
          'subtitle': 'On the way to you',
          'icon': Icons.delivery_dining,
          'color': Colors.purple,
        };
      case 'delivered':
        return {
          'title': 'Delivered',
          'subtitle': 'Enjoy your meal!',
          'icon': Icons.check_circle_outline,
          'color': Colors.green,
        };
      case 'cancelled':
        return {
          'title': 'Cancelled',
          'subtitle': 'Order was cancelled',
          'icon': Icons.cancel,
          'color': Colors.red,
        };
      default:
        return {
          'title': 'Unknown Status',
          'subtitle': '',
          'icon': Icons.help_outline,
          'color': Colors.grey,
        };
    }
  }
}
