import 'package:flutter/material.dart';
import '../models/recommendation.dart';
import '../widgets/recommendation_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Recommendation> searchResults = [];
  bool isSearching = false;

  // Mock search data - In production, call API
  final List<Recommendation> allRestaurants = [
    Recommendation(
      id: 'paradise_1',
      title: 'Paradise Biryani',
      badge: 'Best Deal',
      badgeVariant: 'success',
      price: 320,
      savings: 45,
      platform: 'ONDC',
      deliveryTime: 35,
      rating: 4.5,
      reason: 'Lowest price with fast delivery',
      cuisine: 'Biryani',
      location: 'Jubilee Hills',
    ),
    Recommendation(
      id: 'meghana_1',
      title: 'Meghana Foods',
      badge: 'Fastest',
      badgeVariant: 'warning',
      price: 340,
      savings: 30,
      platform: 'Swiggy',
      deliveryTime: 20,
      rating: 4.6,
      reason: 'Fastest delivery available',
      cuisine: 'Biryani',
      location: 'Koramangala',
    ),
    Recommendation(
      id: 'dominos_1',
      title: "Domino's Pizza",
      badge: 'Top Rated',
      badgeVariant: 'default',
      price: 480,
      savings: 60,
      platform: 'ONDC',
      deliveryTime: 30,
      rating: 4.7,
      reason: 'Highest rated with great deals',
      cuisine: 'Pizza',
      location: 'Indiranagar',
    ),
    Recommendation(
      id: 'mcdonalds_1',
      title: "McDonald's",
      badge: 'Best Deal',
      badgeVariant: 'success',
      price: 280,
      savings: 50,
      platform: 'Zomato',
      deliveryTime: 25,
      rating: 4.3,
      reason: 'Great value meals',
      cuisine: 'Burger',
      location: 'MG Road',
    ),
  ];

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
      searchResults = allRestaurants.where((restaurant) {
        return restaurant.title.toLowerCase().contains(query.toLowerCase()) ||
            restaurant.cuisine.toLowerCase().contains(query.toLowerCase()) ||
            restaurant.location.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search for restaurants, cuisines...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade500),
          ),
          onChanged: _performSearch,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!isSearching && _searchController.text.isEmpty) {
      return _buildPopularSearches();
    }

    if (isSearching && searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for something else',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return RecommendationCard(
          recommendation: searchResults[index],
        );
      },
    );
  }

  Widget _buildPopularSearches() {
    final popularSearches = [
      {'icon': Icons.local_pizza, 'title': 'Pizza', 'color': Colors.orange},
      {'icon': Icons.fastfood, 'title': 'Burger', 'color': Colors.red},
      {'icon': Icons.restaurant, 'title': 'Biryani', 'color': Colors.brown},
      {'icon': Icons.spa, 'title': 'Healthy', 'color': Colors.green},
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Popular Searches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: popularSearches.length,
            itemBuilder: (context, index) {
              final item = popularSearches[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                  ),
                ),
                title: Text(item['title'] as String),
                onTap: () {
                  _searchController.text = item['title'] as String;
                  _performSearch(item['title'] as String);
                },
              );
            },
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'No recent searches',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
