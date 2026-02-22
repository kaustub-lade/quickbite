import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/order.dart';
import '../models/address.dart';
import 'order_success_screen.dart';
import 'saved_addresses_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _instructionsController = TextEditingController();
  
  String _paymentMethod = 'cod';
  bool _isPlacingOrder = false;
  bool _isLoadingAddresses = false;
  bool _useManualAddress = false;
  SavedAddress? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _loadDefaultAddress() async {
    setState(() {
      _isLoadingAddresses = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = Provider.of<ApiService>(context, listen: false);

      if (authProvider.user != null) {
        final addresses = await apiService.getSavedAddresses(authProvider.user!.id);
        
        if (addresses.isNotEmpty) {
          // Find default address or use first one
          final defaultAddress = addresses.firstWhere(
            (addr) => addr.isDefault,
            orElse: () => addresses.first,
          );

          setState(() {
            _selectedAddress = defaultAddress;
            _useManualAddress = false;
          });
        } else {
          // No saved addresses, use manual entry
          setState(() {
            _useManualAddress = true;
          });
        }
      }
    } catch (e) {
      // If loading fails, fall back to manual entry
      setState(() {
        _useManualAddress = true;
      });
    } finally {
      setState(() {
        _isLoadingAddresses = false;
      });
    }
  }

  Future<void> _selectAddress() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user == null) return;

    final selectedAddress = await Navigator.of(context).push<SavedAddress>(
      MaterialPageRoute(
        builder: (context) => SavedAddressesScreen(
          userId: authProvider.user!.id,
          selectMode: true,
          onAddressSelected: (address) {
            Navigator.of(context).pop(address);
          },
        ),
      ),
    );

    if (selectedAddress != null) {
      setState(() {
        _selectedAddress = selectedAddress;
        _useManualAddress = false;
      });
    }
  }

  Future<void> _placeOrder() async {
    // Validate form only if using manual address entry
    if (_useManualAddress && !_formKey.currentState!.validate()) {
      return;
    }

    // Validate that we have an address (either saved or manual)
    if (!_useManualAddress && _selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final apiService = Provider.of<ApiService>(context, listen: false);

      if (authProvider.user == null) {
        throw Exception('Please login to place order');
      }

      if (cartProvider.items.isEmpty) {
        throw Exception('Cart is empty');
      }

      // Build delivery address from saved address or manual entry
      final deliveryAddress = _useManualAddress
          ? {
              'fullAddress': _addressController.text.trim(),
              'landmark': _landmarkController.text.trim().isEmpty 
                  ? null 
                  : _landmarkController.text.trim(),
              'city': _cityController.text.trim(),
              'pincode': _pincodeController.text.trim(),
              'phone': _phoneController.text.trim(),
            }
          : {
              'fullAddress': _selectedAddress!.address,
              'landmark': _selectedAddress!.landmark != null && _selectedAddress!.landmark!.isNotEmpty ? _selectedAddress!.landmark : null,
              'city': _selectedAddress!.city,
              'pincode': _selectedAddress!.pincode,
              'phone': _selectedAddress!.phone,
            };

      final orderData = {
        'userId': authProvider.user!.id,
        'restaurantId': cartProvider.restaurantId,
        'items': cartProvider.items.values.map((item) => {
          'menuItemId': item.menuItem.id,
          'name': item.menuItem.name,
          'price': item.menuItem.price,
          'quantity': item.quantity,
          'isVeg': item.menuItem.isVeg,
          'platform': (item.menuItem.bestDeal?['platform'] as String?) ?? 'swiggy',
        }).toList(),
        'deliveryAddress': deliveryAddress,
        'platform': (cartProvider.items.values.first.menuItem.bestDeal?['platform'] as String?) ?? 'swiggy',
        'paymentMethod': _paymentMethod,
        'specialInstructions': _instructionsController.text.trim().isEmpty 
            ? null 
            : _instructionsController.text.trim(),
      };

      // If online payment is selected, process payment first
      if (_paymentMethod == 'online') {
        final response = await apiService.placeOrder(orderData);

        if (response['success'] == true) {
          // Order created, now process payment
          final orderId = response['order']['id'];
          final totalAmount = cartProvider.totalAmount;

          // Show payment processing dialog
          if (!mounted) return;
          final paymentSuccess = await _processOnlinePayment(
            apiService, 
            orderId, 
            totalAmount
          );

          if (!paymentSuccess) {
            throw Exception('Payment was cancelled or failed');
          }

          // Payment successful, clear cart and navigate
          cartProvider.clear();

          if (!mounted) return;

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => OrderSuccessScreen(
                orderNumber: response['order']['orderNumber'],
                orderId: orderId,
              ),
            ),
          );
        }
      } else {
        // Cash on Delivery - proceed as before
        final response = await apiService.placeOrder(orderData);

        if (response['success'] == true) {
          cartProvider.clear();

          if (!mounted) return;

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => OrderSuccessScreen(
                orderNumber: response['order']['orderNumber'],
                orderId: response['order']['id'],
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  Future<bool> _processOnlinePayment(
    ApiService apiService,
    String orderId,
    double totalAmount,
  ) async {
    try {
      // Show payment dialog
      if (!mounted) return false;
      
      final paymentConfirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _PaymentDialog(
          orderId: orderId,
          amount: totalAmount,
          apiService: apiService,
        ),
      );

      return paymentConfirmed ?? false;
    } catch (e) {
      print('Payment processing error: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    
    if (cartProvider.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(
          child: Text('Your cart is empty'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Order Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cartProvider.restaurantName ?? 'Restaurant',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(height: 24),
                    ...cartProvider.items.values.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text('${item.quantity}x '),
                          Expanded(child: Text(item.menuItem.name)),
                          Text('₹${item.totalPrice.toStringAsFixed(0)}'),
                        ],
                      ),
                    )),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${cartProvider.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEA580C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Delivery Address Section
            Text(
              'Delivery Address',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            if (_isLoadingAddresses)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (!_useManualAddress && _selectedAddress != null)
              // Show selected saved address
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFEA580C), width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEA580C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _selectedAddress!.iconForLabel,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _selectedAddress!.displayLabel,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (_selectedAddress!.isDefault) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEA580C),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'DEFAULT',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedAddress!.fullAddress,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '+91 ${_selectedAddress!.phone}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectAddress,
                              icon: const Icon(Icons.edit_location),
                              label: const Text('Change Address'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFEA580C),
                                side: const BorderSide(color: Color(0xFFEA580C)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _useManualAddress = true;
                                  _selectedAddress = null;
                                });
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('New Address'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEA580C),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              // Show manual address form
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_useManualAddress && _selectedAddress == null)
                    Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.orange.shade700),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'No saved addresses found. Please enter your delivery address.',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!_useManualAddress && _selectedAddress == null)
                    const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Full Address *',
                      hintText: 'House/Flat No., Street, Area',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _landmarkController,
                    decoration: const InputDecoration(
                      labelText: 'Landmark (Optional)',
                      hintText: 'e.g., Near City Mall',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'City *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _pincodeController,
                          decoration: const InputDecoration(
                            labelText: 'Pincode *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            if (value.length != 6) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number *',
                      hintText: '10-digit mobile number',
                      border: OutlineInputBorder(),
                      prefixText: '+91 ',
                    ),
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length != 10) {
                        return 'Please enter valid 10-digit number';
                      }
                      return null;
                    },
                  ),
                  if (_selectedAddress == null)
                    TextButton.icon(
                      onPressed: _selectAddress,
                      icon: const Icon(Icons.bookmark),
                      label: const Text('Choose from saved addresses'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFEA580C),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 24),

            // Payment Method
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text('Cash on Delivery'),
              value: 'cod',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
              activeColor: const Color(0xFFEA580C),
            ),
            RadioListTile<String>(
              title: const Text('Online Payment'),
              subtitle: const Text('UPI, Cards, Wallets'),
              value: 'online',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
              activeColor: const Color(0xFFEA580C),
            ),
            const SizedBox(height: 24),

            // Special Instructions
            Text(
              'Special Instructions (Optional)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                hintText: 'e.g., Extra spicy, No onions',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            // Place Order Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isPlacingOrder ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA580C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isPlacingOrder
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Place Order - ₹${cartProvider.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Payment Dialog Widget
class _PaymentDialog extends StatefulWidget {
  final String orderId;
  final double amount;
  final ApiService apiService;

  const _PaymentDialog({
    required this.orderId,
    required this.amount,
    required this.apiService,
  });

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  bool _isProcessing = true;
  String _status = 'Initializing payment...';
  bool _paymentSuccess = false;

  @override
  void initState() {
    super.initState();
    _initiatePayment();
  }

  Future<void> _initiatePayment() async {
    try {
      setState(() {
        _status = 'Creating payment order...';
      });

      // Create Razorpay order
      final paymentOrder = await widget.apiService.createPaymentOrder(
        amount: widget.amount,
        orderId: widget.orderId,
        receipt: 'receipt_${widget.orderId}',
      );

      if (!paymentOrder['success']) {
        throw Exception(paymentOrder['error'] ?? 'Failed to create payment order');
      }

      setState(() {
        _status = 'Processing payment...';
      });

      // Simulate payment processing (in production, this would open Razorpay SDK)
      await Future.delayed(const Duration(seconds: 2));

      // Mock payment response (in production, this comes from Razorpay SDK)
      final razorpayOrderId = paymentOrder['order']['id'];
      final razorpayPaymentId = 'pay_${DateTime.now().millisecondsSinceEpoch}';
      final razorpaySignature = 'mock_signature_${DateTime.now().millisecondsSinceEpoch}';

      setState(() {
        _status = 'Verifying payment...';
      });

      // Verify payment
      final verifyResponse = await widget.apiService.verifyPayment(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
        orderId: widget.orderId,
      );

      if (verifyResponse['success']) {
        setState(() {
          _status = 'Payment successful!';
          _paymentSuccess = true;
          _isProcessing = false;
        });

        // Auto-close dialog after 2 seconds
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception(verifyResponse['error'] ?? 'Payment verification failed');
      }
    } catch (e) {
      setState(() {
        _status = 'Payment failed: ${e.toString()}';
        _paymentSuccess = false;
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Online Payment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isProcessing)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEA580C)),
            ),
          if (!_isProcessing && _paymentSuccess)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
          if (!_isProcessing && !_paymentSuccess)
            const Icon(
              Icons.error,
              color: Colors.red,
              size: 64,
            ),
          const SizedBox(height: 16),
          Text(
            _status,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${widget.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEA580C),
            ),
          ),
        ],
      ),
      actions: [
        if (!_isProcessing && !_paymentSuccess)
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
        if (!_isProcessing && !_paymentSuccess)
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isProcessing = true;
                _status = 'Retrying payment...';
              });
              _initiatePayment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA580C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
      ],
    );
  }
}
