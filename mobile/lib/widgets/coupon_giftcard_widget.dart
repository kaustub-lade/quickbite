import 'package:flutter/material.dart';

class CouponGiftCardWidget extends StatefulWidget {
  final Function(String code, String type) onApply;
  final Function(String type) onRemove;
  final Map<String, dynamic>? appliedCoupon;
  final Map<String, dynamic>? appliedGiftCard;

  const CouponGiftCardWidget({
    Key? key,
    required this.onApply,
    required this.onRemove,
    this.appliedCoupon,
    this.appliedGiftCard,
  }) : super(key: key);

  @override
  State<CouponGiftCardWidget> createState() => _CouponGiftCardWidgetState();
}

class _CouponGiftCardWidgetState extends State<CouponGiftCardWidget> {
  final _couponController = TextEditingController();
  final _giftCardController = TextEditingController();
  bool _showCouponInput = false;
  bool _showGiftCardInput = false;

  @override
  void dispose() {
    _couponController.dispose();
    _giftCardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Coupons & Gift Cards',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Coupon Section
          _buildCouponSection(),
          
          const SizedBox(height: 12),
          
          // Gift Card Section
          _buildGiftCardSection(),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    final hasAppliedCoupon = widget.appliedCoupon != null;

    if (hasAppliedCoupon) {
      return _buildAppliedCard(
        icon: Icons.local_offer,
        color: Colors.green,
        title: 'Coupon Applied',
        subtitle: widget.appliedCoupon!['code'],
        discount: '₹${widget.appliedCoupon!['discountAmount']?.toStringAsFixed(0) ?? '0'} off',
        onRemove: () => widget.onRemove('coupon'),
      );
    }

    if (_showCouponInput) {
      return _buildInputCard(
        controller: _couponController,
        hint: 'Enter coupon code',
        icon: Icons.local_offer,
        color: Colors.orange,
        onApply: () {
          if (_couponController.text.trim().isNotEmpty) {
            widget.onApply(_couponController.text.trim().toUpperCase(), 'coupon');
          }
        },
        onCancel: () {
          setState(() {
            _showCouponInput = false;
            _couponController.clear();
          });
        },
      );
    }

    return _buildAddButton(
      icon: Icons.local_offer,
      text: 'Apply Coupon',
      color: const Color(0xFFEA580C),
      onTap: () {
        setState(() {
          _showCouponInput = true;
        });
      },
    );
  }

  Widget _buildGiftCardSection() {
    final hasAppliedGiftCard = widget.appliedGiftCard != null;

    if (hasAppliedGiftCard) {
      return _buildAppliedCard(
        icon: Icons.card_giftcard,
        color: Colors.purple,
        title: 'Gift Card Applied',
        subtitle: widget.appliedGiftCard!['code'],
        discount: '₹${widget.appliedGiftCard!['amountUsed']?.toStringAsFixed(0) ?? '0'} used',
        onRemove: () => widget.onRemove('giftcard'),
      );
    }

    if (_showGiftCardInput) {
      return _buildInputCard(
        controller: _giftCardController,
        hint: 'Enter gift card code',
        icon: Icons.card_giftcard,
        color: Colors.purple,
        onApply: () {
          if (_giftCardController.text.trim().isNotEmpty) {
            widget.onApply(_giftCardController.text.trim().toUpperCase(), 'giftcard');
          }
        },
        onCancel: () {
          setState(() {
            _showGiftCardInput = false;
            _giftCardController.clear();
          });
        },
      );
    }

    return _buildAddButton(
      icon: Icons.card_giftcard,
      text: 'Apply Gift Card',
      color: Colors.purple,
      onTap: () {
        setState(() {
          _showGiftCardInput = true;
        });
      },
    );
  }

  Widget _buildAddButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color color,
    required VoidCallback onApply,
    required VoidCallback onCancel,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.05),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    isDense: true,
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppliedCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String discount,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                discount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: onRemove,
                child: Text(
                  'Remove',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
