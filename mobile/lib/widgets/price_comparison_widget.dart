import 'package:flutter/material.dart';
import '../models/platform_price.dart';

class PriceComparisonWidget extends StatefulWidget {
  final String itemName;
  final List<PlatformPrice> platformPrices;
  final BestDeal? bestDeal;
  final bool compact; // If true, show condensed version

  const PriceComparisonWidget({
    super.key,
    required this.itemName,
    required this.platformPrices,
    this.bestDeal,
    this.compact = false,
  });

  @override
  State<PriceComparisonWidget> createState() => _PriceComparisonWidgetState();
}

class _PriceComparisonWidgetState extends State<PriceComparisonWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.platformPrices.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.compact) {
      return _buildCompactView();
    }

    return _buildFullView();
  }

  Widget _buildCompactView() {
    // Show just the best deal badge
    final bestPrice = widget.platformPrices.firstWhere(
      (p) => p.isBestDeal,
      orElse: () => widget.platformPrices.first,
    );

    final maxSavings = widget.platformPrices
        .map((p) => p.savings)
        .reduce((max, s) => s > max ? s : max);

    if (maxSavings <= 0) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade700],
              ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_offer,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  'Best Deal on ${bestPrice.platform}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'Save ₹${maxSavings.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 8),
            _buildPriceList(),
          ],
        ],
      ),
    );
  }

  Widget _buildFullView() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.compare_arrows,
                size: 18,
                color: Colors.orange.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                'Price Comparison',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPriceList(),
        ],
      ),
    );
  }

  Widget _buildPriceList() {
    // Sort by price (lowest first)
    final sortedPrices = List<PlatformPrice>.from(widget.platformPrices)
      ..sort((a, b) => a.price.compareTo(b.price));

    return Column(
      children: sortedPrices.map((platformPrice) {
        return _buildPriceRow(platformPrice);
      }).toList(),
    );
  }

  Widget _buildPriceRow(PlatformPrice platformPrice) {
    final isBest = platformPrice.isBestDeal;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isBest ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isBest ? Colors.green.shade300 : Colors.grey.shade200,
          width: isBest ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Platform logo placeholder
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getPlatformColor(platformPrice.platform),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                _getPlatformInitial(platformPrice.platform),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Platform name and delivery time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platformPrice.platform,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isBest ? FontWeight.bold : FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${platformPrice.deliveryTime} mins',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Price and savings
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${platformPrice.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isBest ? Colors.green.shade700 : Colors.grey.shade900,
                ),
              ),
              if (isBest)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'BEST',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              else if (platformPrice.savings > 0)
                Text(
                  '+₹${platformPrice.savings.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          
          // Best deal icon
          if (isBest) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.star,
              color: Colors.green.shade600,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'swiggy':
        return const Color(0xFFFC8019); // Swiggy orange
      case 'zomato':
        return const Color(0xFFE23744); // Zomato red
      case 'ondc':
        return const Color(0xFF2874F0); // ONDC blue
      default:
        return Colors.grey.shade600;
    }
  }

  String _getPlatformInitial(String platform) {
    if (platform.isEmpty) return '?';
    return platform[0].toUpperCase();
  }
}
