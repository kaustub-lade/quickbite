import 'package:flutter/material.dart';
import '../screens/restaurant_detail_screen.dart';
import '../widgets/custom_page_route.dart';

class BestDealCard extends StatelessWidget {
  final Map<String, dynamic> deal;

  const BestDealCard({
    super.key,
    required this.deal,
  });

  @override
  Widget build(BuildContext context) {
    final savings = deal['savings'] ?? 0;
    final savingsPercent = deal['savingsPercent'] ?? 0;
    final originalPrice = deal['originalPrice'] ?? 0;
    final bestPrice = deal['bestPrice'] ?? 0;
    final platform = deal['bestPlatform'] ?? 'swiggy';
    final restaurant = deal['restaurant'];

    return GestureDetector(
      onTap: () {
        if (restaurant != null && restaurant['id'] != null) {
          Navigator.push(
            context,
            SlidePageRoute(
              page: RestaurantDetailScreen(
                restaurantId: restaurant['id'],
                restaurantName: restaurant['name'] ?? 'Restaurant',
                cuisine: deal['category'] ?? 'Various',
                rating: (restaurant['rating'] ?? 4.0).toDouble(),
                deliveryTime: restaurant['deliveryTime'] ?? 30,
                location: restaurant['location'] ?? 'Location',
              ),
            ),
          );
        }
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Savings Badge Stack
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  // Item Image
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                    ),
                    child: deal['imageUrl'] != null && deal['imageUrl'].toString().isNotEmpty
                        ? Image.network(
                            deal['imageUrl'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder();
                            },
                          )
                        : _buildPlaceholder(),
                  ),
                  
                  // Savings Badge (Top Right)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_offer, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'SAVE ₹$savings',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Veg/Non-veg Indicator (Top Left)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: deal['isVeg'] == true ? Colors.green : Colors.red,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: deal['isVeg'] == true ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Name
                  Text(
                    deal['name'] ?? 'Item',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Restaurant Name
                  if (restaurant != null)
                    Text(
                      restaurant['name'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  
                  // Pricing Section
                  Row(
                    children: [
                      // Original Price (struck through)
                      Text(
                        '₹$originalPrice',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Best Price
                      Text(
                        '₹$bestPrice',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEA580C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Platform Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPlatformColor(platform).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _getPlatformColor(platform).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.storefront,
                          size: 12,
                          color: _getPlatformColor(platform),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          platform.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getPlatformColor(platform),
                          ),
                        ),
                      ],
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

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.fastfood,
        size: 50,
        color: Colors.grey.shade400,
      ),
    );
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'swiggy':
        return const Color(0xFFFC8019);
      case 'zomato':
        return const Color(0xFFE23744);
      case 'ondc':
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFFEA580C);
    }
  }
}
