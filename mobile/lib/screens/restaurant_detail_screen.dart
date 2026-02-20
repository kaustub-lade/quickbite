import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import '../providers/cart_provider.dart';
import '../widgets/menu_item_card.dart';
import 'cart_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;
  final String cuisine;
  final double rating;
  final int deliveryTime;
  final String location;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
    required this.cuisine,
    required this.rating,
    required this.deliveryTime,
    required this.location,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  bool isVegOnly = false;
  String selectedCategory = 'All';
  
  // Mock menu items - In production, fetch from API
  final List<MenuItem> menuItems = [
    MenuItem(
      id: '1',
      name: 'Chicken Biryani',
      description: 'Hyderabadi style with raita and salan',
      price: 320,
      imageUrl: '',
      isVeg: false,
      isBestseller: true,
      rating: 4.5,
      ratingsCount: 234,
      category: 'Biryani',
    ),
    MenuItem(
      id: '2',
      name: 'Veg Biryani',
      description: 'Mixed vegetables with aromatic spices',
      price: 280,
      imageUrl: '',
      isVeg: true,
      rating: 4.3,
      ratingsCount: 156,
      category: 'Biryani',
    ),
    MenuItem(
      id: '3',
      name: 'Paneer Tikka',
      description: 'Tandoori paneer with mint chutney',
      price: 240,
      imageUrl: '',
      isVeg: true,
      isBestseller: true,
      rating: 4.6,
      ratingsCount: 189,
      category: 'Starters',
    ),
    MenuItem(
      id: '4',
      name: 'Chicken 65',
      description: 'Spicy fried chicken with curry leaves',
      price: 260,
      imageUrl: '',
      isVeg: false,
      rating: 4.4,
      ratingsCount: 201,
      category: 'Starters',
    ),
    MenuItem(
      id: '5',
      name: 'Butter Naan',
      description: 'Soft naan with butter',
      price: 40,
      imageUrl: '',
      isVeg: true,
      rating: 4.2,
      ratingsCount: 98,
      category: 'Breads',
    ),
  ];

  List<String> get categories {
    final cats = menuItems.map((item) => item.category).toSet().toList();
    return ['All', ...cats];
  }

  List<MenuItem> get filteredItems {
    return menuItems.where((item) {
      final categoryMatch = selectedCategory == 'All' || item.category == selectedCategory;
      final vegMatch = !isVegOnly || item.isVeg;
      return categoryMatch && vegMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFFEA580C),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFEA580C).withOpacity(0.7),
                          const Color(0xFFDC2626),
                        ],
                      ),
                    ),
                    child: const Icon(Icons.restaurant, size: 80, color: Colors.white54),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.restaurantName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.cuisine,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Restaurant Info
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildInfoChip(Icons.star, '${widget.rating}', Colors.green),
                  const SizedBox(width: 12),
                  _buildInfoChip(Icons.access_time, '${widget.deliveryTime} mins', Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoChip(Icons.location_on, widget.location, Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          // Offers
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(Icons.local_offer, color: Color(0xFFEA580C), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '50% off up to ₹100 | Use code QUICKBITE',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filters
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Text('Veg Only', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 8),
                          Switch(
                            value: isVegOnly,
                            onChanged: (value) {
                              setState(() {
                                isVegOnly = value;
                              });
                            },
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = selectedCategory == category;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFEA580C) : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          SliverPadding(
            padding: const EdgeInsets.only(top: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return MenuItemCard(
                    menuItem: filteredItems[index],
                    restaurantId: widget.restaurantId,
                    restaurantName: widget.restaurantName,
                  );
                },
                childCount: filteredItems.length,
              ),
            ),
          ),

          // Bottom Padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      
      // Floating Cart Button
      bottomNavigationBar: cart.isEmpty
          ? null
          : Container(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartScreen()),
                      );
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${cart.totalQuantity}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'View Cart',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '₹${cart.totalAmount.toStringAsFixed(0)}',
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
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color == Colors.green ? Colors.green : Colors.grey.shade700,
              fontWeight: color == Colors.green ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
