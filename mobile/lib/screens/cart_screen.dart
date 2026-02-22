import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../models/restaurant.dart';
import '../services/api_service.dart';
import '../widgets/coupon_giftcard_widget.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, dynamic>? _appliedCoupon;
  Map<String, dynamic>? _appliedGiftCard;
  bool _isProcessing = false;

  Future<void> _handleApply(String code, String type) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final cart = context.read<CartProvider>();
      final authProvider = context.read<AuthProvider>();
      final apiService = context.read<ApiService>();

      if (authProvider.token == null) {
        _showSnackBar('Please login to apply $type', Colors.red);
        return;
      }

      if (type == 'coupon') {
        final response = await apiService.validateCoupon(
          token: authProvider.token!,
          code: code,
          orderAmount: cart.totalAmount,
          restaurantId: cart.restaurantId ?? '',
          items: cart.items.map((item) => {
            'id': item.id,
            'name': item.name,
            'category': item.category ?? '',
            'price': item.price,
            'quantity': item.quantity,
          }).toList(),
        );

        if (response['success'] == true) {
          setState(() {
            _appliedCoupon = response['coupon'];
          });
          _showSnackBar('Coupon applied successfully!', Colors.green);
        } else {
          _showSnackBar(response['error'] ?? 'Invalid coupon', Colors.red);
        }
      } else if (type == 'giftcard') {
        final response = await apiService.checkGiftCard(
          token: authProvider.token!,
          code: code,
        );

        if (response['success'] == true) {
          final giftCard = response['giftCard'];
          final balance = giftCard['balance'] as num;
          final amountToUse = balance > cart.totalAmount
              ? cart.totalAmount
              : balance.toDouble();

          setState(() {
            _appliedGiftCard = {
              ...giftCard,
              'amountUsed': amountToUse,
            };
          });
          _showSnackBar('Gift card applied successfully!', Colors.green);
        } else {
          _showSnackBar(response['error'] ?? 'Invalid gift card', Colors.red);
        }
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _handleRemove(String type) {
    setState(() {
      if (type == 'coupon') {
        _appliedCoupon = null;
      } else if (type == 'giftcard') {
        _appliedGiftCard = null;
      }
    });
    _showSnackBar('${type == 'coupon' ? 'Coupon' : 'Gift card'} removed', Colors.grey);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  double _calculateTotal(CartProvider cart) {
    double total = cart.totalAmount;
    
    // Add fees
    total += 40; // Delivery fee
    total += 5;  // Platform fee
    total += cart.totalAmount * 0.05; // GST

    // Apply coupon discount
    if (_appliedCoupon != null) {
      final discountAmount = (_appliedCoupon!['discountAmount'] as num?)?.toDouble() ?? 0.0;
      final deliveryDiscount = (_appliedCoupon!['deliveryDiscount'] as num?)?.toDouble() ?? 0.0;
      total -= (discountAmount + deliveryDiscount);
    }

    // Apply gift card
    if (_appliedGiftCard != null) {
      final amountUsed = (_appliedGiftCard!['amountUsed'] as num?)?.toDouble() ?? 0.0;
      total -= amountUsed;
    }

    return total > 0 ? total : 0;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Cart',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (cart.restaurantName != null)
              Text(
                cart.restaurantName!,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
          ],
        ),
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add items to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Cart Items
                        Container(
                          color: Colors.white,
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cart.items.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: Colors.grey.shade200,
                            ),
                            itemBuilder: (context, index) {
                              final cartItem = cart.items.values.toList()[index];
                              return _buildCartItem(context, cart, cartItem);
                            },
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Coupons and Gift Cards
                        CouponGiftCardWidget(
                          onApply: _handleApply,
                          onRemove: _handleRemove,
                          appliedCoupon: _appliedCoupon,
                          appliedGiftCard: _appliedGiftCard,
                        ),

                        const SizedBox(height: 12),

                        // Bill Details
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bill Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildBillRow('Item Total', cart.totalAmount),
                              const SizedBox(height: 8),
                              _buildBillRow('Delivery Fee', 40, color: Colors.grey.shade700),
                              const SizedBox(height: 8),
                              _buildBillRow('Platform Fee', 5, color: Colors.grey.shade700),
                              const SizedBox(height: 8),
                              _buildBillRow('GST and Restaurant Charges', cart.totalAmount * 0.05, color: Colors.grey.shade700),
                              
                              // Show coupon discount
                              if (_appliedCoupon != null) ...[
                                const SizedBox(height: 8),
                                _buildBillRow(
                                  'Coupon Discount (${_appliedCoupon!['code']})',
                                  -(_appliedCoupon!['discountAmount'] as num).toDouble(),
                                  color: Colors.green,
                                ),
                                if ((_appliedCoupon!['deliveryDiscount'] as num?) != null && 
                                    (_appliedCoupon!['deliveryDiscount'] as num) > 0) ...[
                                  const SizedBox(height: 8),
                                  _buildBillRow(
                                    'Delivery Discount',
                                    -(_appliedCoupon!['deliveryDiscount'] as num).toDouble(),
                                    color: Colors.green,
                                  ),
                                ],
                              ],
                              
                              // Show gift card discount
                              if (_appliedGiftCard != null) ...[
                                const SizedBox(height: 8),
                                _buildBillRow(
                                  'Gift Card Applied',
                                  -(_appliedGiftCard!['amountUsed'] as num).toDouble(),
                                  color: Colors.purple,
                                ),
                              ],
                              
                              const SizedBox(height: 12),
                              Divider(color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              _buildBillRow(
                                'TO PAY',
                                _calculateTotal(cart),
                                isBold: true,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Cancellation Policy
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 18, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Review your order and address details to avoid cancellations',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),

                // Checkout Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: () {
                          _showCheckoutDialog(context, cart);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA580C),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Proceed to Checkout',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '₹${(cart.totalAmount + 40 + 5 + (cart.totalAmount * 0.05)).toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartProvider cart, CartItem cartItem) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Veg/Non-veg indicator
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              border: Border.all(
                color: cartItem.menuItem.isVeg ? Colors.green : Colors.red,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cartItem.menuItem.isVeg ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.menuItem.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${cartItem.menuItem.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Quantity controls
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => cart.removeItem(cartItem.menuItem.id),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.remove,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${cartItem.quantity}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => cart.addItem(
                    cartItem.menuItem,
                    cart.restaurantId!,
                    cart.restaurantName!,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.add,
                      size: 16,
                      color: Color(0xFFEA580C),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Total price
          Text(
            '₹${cartItem.totalPrice.toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, double amount, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }

  void _showCheckoutDialog(BuildContext context, CartProvider cart) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if user is logged in
    if (authProvider.user == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text('Please login to place an order.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA580C),
              ),
              child: const Text('LOGIN'),
            ),
          ],
        ),
      );
      return;
    }

    // Navigate to checkout screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CheckoutScreen(),
      ),
    );
  }
}
