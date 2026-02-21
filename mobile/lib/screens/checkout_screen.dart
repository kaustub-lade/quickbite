import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/order.dart';
import 'order_success_screen.dart';

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

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
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

      final orderData = {
        'userId': authProvider.user!['id'],
        'restaurantId': cartProvider.restaurant!['id'],
        'items': cartProvider.items.map((item) => {
          'menuItemId': item.id,
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity,
          'isVeg': item.isVeg,
          'platform': item.platform,
        }).toList(),
        'deliveryAddress': {
          'fullAddress': _addressController.text.trim(),
          'landmark': _landmarkController.text.trim().isEmpty 
              ? null 
              : _landmarkController.text.trim(),
          'city': _cityController.text.trim(),
          'pincode': _pincodeController.text.trim(),
          'phone': _phoneController.text.trim(),
        },
        'platform': cartProvider.items[0].platform,
        'paymentMethod': _paymentMethod,
        'specialInstructions': _instructionsController.text.trim().isEmpty 
            ? null 
            : _instructionsController.text.trim(),
      };

      final response = await apiService.placeOrder(orderData);

      if (response['success'] == true) {
        // Clear cart after successful order
        cartProvider.clear();

        if (!mounted) return;

        // Navigate to success screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OrderSuccessScreen(
              orderNumber: response['order']['orderNumber'],
              orderId: response['order']['id'],
            ),
          ),
        );
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
                      cartProvider.restaurant!['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(height: 24),
                    ...cartProvider.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text('${item.quantity}x '),
                          Expanded(child: Text(item.name)),
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
              title: const Text('Online Payment (Coming Soon)'),
              subtitle: const Text('UPI, Cards, Wallets'),
              value: 'online',
              groupValue: _paymentMethod,
              onChanged: null, // Disabled for now
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
