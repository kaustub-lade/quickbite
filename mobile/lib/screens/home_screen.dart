import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/recommendation.dart';
import '../widgets/category_card.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/custom_page_route.dart';
import '../providers/cart_provider.dart';
import '../widgets/best_deal_card.dart';
import 'search_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'restaurant_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCategory;
  List<Recommendation> recommendations = [];
  List<dynamic> popularRestaurants = [];
  List<dynamic> trendingItems = [];
  List<dynamic> bestDeals = [];
  Map<String, dynamic> restaurantStats = {};
  bool isLoading = false;
  bool isLoadingPopular = false;
  bool isLoadingTrending = false;
  bool isLoadingDeals = false;
  String? error;

  final List<Map<String, String>> categories = [
    {'emoji': '🍛', 'label': 'Biryani', 'value': 'biryani'},
    {'emoji': '🍕', 'label': 'Pizza', 'value': 'pizza'},
    {'emoji': '🍔', 'label': 'Burger', 'value': 'burger'},
    {'emoji': '🥗', 'label': 'Healthy', 'value': 'healthy'},
  ];

  @override
  void initState() {
    super.initState();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    // Load popular restaurants, trending items, stats, and best deals in parallel
    setState(() {
      isLoadingPopular = true;
      isLoadingTrending = true;
      isLoadingDeals = true;
    });

    try {
      final apiService = context.read<ApiService>();
      
      // Fetch all data in parallel
      final results = await Future.wait([
        apiService.getPopularRestaurants(),
        apiService.getTrendingItems(),
        apiService.getRestaurantStats(),
        apiService.getBestDeals(limit: 15),
      ]);

      setState(() {
        popularRestaurants = results[0] as List<dynamic>;
        trendingItems = results[1] as List<dynamic>;
        restaurantStats = results[2] as Map<String, dynamic>;
        bestDeals = results[3] as List<dynamic>;
        isLoadingPopular = false;
        isLoadingTrending = false;
        isLoadingDeals = false;
      });
    } catch (e) {
      setState(() {
        isLoadingPopular = false;
        isLoadingTrending = false;
      });
      // Silently fail - show empty sections instead of errors
    }
  }

  int getCategoryCount(String category) {
    if (restaurantStats.isEmpty) return 0;
    final categoryCount = restaurantStats['categoryCount'];
    if (categoryCount == null) return 0;
    return categoryCount[category] ?? 0;
  }

  int _parseDeliveryTime(dynamic value) {
    if (value == null) return 30;
    if (value is int) return value;
    if (value is String) {
      // Extract first number from string like "30-40 mins" or "30 mins"
      final match = RegExp(r'\d+').firstMatch(value);
      if (match != null) {
        return int.tryParse(match.group(0)!) ?? 30;
      }
    }
    return 30;
  }

  double _parseRating(dynamic value) {
    if (value == null) return 4.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 4.0;
    }
    return 4.0;
  }

  Future<void> fetchRecommendations(String category) async {
    setState(() {
      isLoading = true;
      error = null;
      selectedCategory = category;
    });

    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.getRecommendations(category);
      
      setState(() {
        recommendations = response.recommendations;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar with Search
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '🍽️ QuickBite',
                        style: TextStyle(
                          color: Color(0xFFEA580C),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Beta',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Smart food ordering',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.account_circle_outlined, color: Color(0xFFEA580C)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(page: const ProfileScreen()),
                    );
                  },
                ),
                if (!cart.isEmpty)
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFFEA580C)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            SlidePageRoute(page: const CartScreen()),
                          );
                        },
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${cart.totalQuantity}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(page: const SearchScreen()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey.shade500),
                      const SizedBox(width: 12),
                      Text(
                        'Search for restaurants, cuisines...',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Best Deals Section
            if (selectedCategory == null && !isLoadingDeals && bestDeals.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.local_offer, color: Color(0xFFEA580C), size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        '🔥 Best Deals',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: bestDeals.length,
                    itemBuilder: (context, index) {
                      final deal = bestDeals[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: BestDealCard(deal: deal),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],

            // Popular Near You Section
            if (selectedCategory == null && !isLoadingPopular && popularRestaurants.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Color(0xFFEA580C), size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Popular Near You',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: popularRestaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = popularRestaurants[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            SlidePageRoute(
                              page: RestaurantDetailScreen(
                                restaurantId: restaurant['id'] ?? restaurant['_id'] ?? '',
                                restaurantName: restaurant['name'] ?? 'Restaurant',
                                cuisine: restaurant['cuisine'] ?? 'Various',
                                rating: _parseRating(restaurant['rating']),
                                deliveryTime: _parseDeliveryTime(restaurant['deliveryTime']),
                                location: restaurant['location'] ?? 'Location',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 280,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Restaurant Image Placeholder
                              Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFEA580C).withOpacity(0.3), Color(0xFFDC2626).withOpacity(0.3)],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(Icons.restaurant, size: 40, color: Color(0xFFEA580C)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      restaurant['name'] ?? 'Restaurant',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${restaurant['rating'] ?? 4.0}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          restaurant['deliveryTime'] ?? '30 mins',
                                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                    if (restaurant['orderCount'] != null && restaurant['orderCount'] > 0) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '${restaurant['orderCount']} orders',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFEA580C),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ));
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],

            // Trending Now Section
            if (selectedCategory == null && !isLoadingTrending && trendingItems.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, color: Color(0xFFEA580C), size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Trending Now',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: trendingItems.length,
                    itemBuilder: (context, index) {
                      final item = trendingItems[index];
                      return GestureDetector(
                        onTap: () {
                          if (item['restaurant'] != null) {
                            Navigator.push(
                              context,
                              SlidePageRoute(
                                page: RestaurantDetailScreen(
                                  restaurantId: item['restaurant']['id'] ?? item['restaurant']['_id'] ?? '',
                                  restaurantName: item['restaurant']['name'] ?? 'Restaurant',
                                  cuisine: item['restaurant']['cuisine'] ?? item['category'] ?? 'Various',
                                  rating: _parseRating(item['restaurant']['rating']),
                                  deliveryTime: _parseDeliveryTime(item['restaurant']['deliveryTime']),
                                  location: item['restaurant']['location'] ?? 'Location',
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: item['isVeg'] == true ? Colors.green : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    item['name'] ?? 'Item',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (item['restaurant'] != null)
                              Text(
                                item['restaurant']['name'] ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₹${item['price']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFEA580C),
                                  ),
                                ),
                                if (item['orderCount'] != null && item['orderCount'] > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFEA580C).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${item['orderCount']} sold',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFEA580C),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ));
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 0)),

            // Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  selectedCategory == null 
                      ? "What would you like to eat?"
                      : 'Top picks for $selectedCategory',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Category Selection
            if (selectedCategory == null)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = categories[index];
                      final count = getCategoryCount(category['value']!);
                      return GestureDetector(
                        onTap: () => fetchRecommendations(category['value']!),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                category['emoji']!,
                                style: const TextStyle(fontSize: 48),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category['label']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (count > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '$count restaurants',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: categories.length,
                  ),
                ),
              ),

            // Recommendations Section
            if (selectedCategory != null) ...[
              // Back to categories button  
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedCategory = null;
                        recommendations = [];
                      });
                    },
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Back to categories'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFEA580C),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Loading State
              if (isLoading)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const RestaurantCardSkeleton(),
                      childCount: 3,
                    ),
                  ),
                ),

              // Error State
              if (error != null && !isLoading)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 60, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => fetchRecommendations(selectedCategory!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEA580C),
                            ),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Recommendations List
              if (!isLoading && error == null && recommendations.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return RecommendationCard(
                          recommendation: recommendations[index],
                        );
                      },
                      childCount: recommendations.length,
                    ),
                  ),
                ),

              // No Results
              if (!isLoading && error == null && recommendations.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant, size: 60, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No restaurants found for $selectedCategory',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Try another category!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],

            // Stats Card (when no category selected)
            if (selectedCategory == null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFEA580C).withOpacity(0.9),
                          const Color(0xFFDC2626).withOpacity(0.9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Impact This Month',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '₹0',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Saved',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 32),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '0',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Orders',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '🚀 Start ordering to see your savings grow!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Bottom padding for floating cart button
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
