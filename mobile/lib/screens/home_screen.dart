import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/recommendation.dart';
import '../widgets/category_card.dart';
import '../widgets/recommendation_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCategory;
  List<Recommendation> recommendations = [];
  bool isLoading = false;
  String? error;

  final List<Map<String, String>> categories = [
    {'emoji': '🍛', 'label': 'Biryani', 'value': 'biryani'},
    {'emoji': '🍕', 'label': 'Pizza', 'value': 'pizza'},
    {'emoji': '🍔', 'label': 'Burger', 'value': 'burger'},
    {'emoji': '🥗', 'label': 'Healthy', 'value': 'healthy'},
  ];

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
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
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
            const Text(
              'Your AI food assistant',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              const Text(
                'Good evening! 👋',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'What are you in the mood for?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

              // Category Selection
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: categories.map((category) {
                  final isSelected = selectedCategory == category['value'];
                  return CategoryCard(
                    emoji: category['emoji']!,
                    label: category['label']!,
                    isSelected: isSelected,
                    onTap: () => fetchRecommendations(category['value']!),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Recommendations Section
              if (selectedCategory != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top picks for $selectedCategory',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isLoading && recommendations.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${recommendations.length} restaurants',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Loading State
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48.0),
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: Color(0xFFEA580C)),
                          SizedBox(height: 16),
                          Text('Finding the best deals for you...'),
                        ],
                      ),
                    ),
                  ),

                // Error State
                if (error != null && !isLoading)
                  Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => fetchRecommendations(selectedCategory!),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Recommendations List
                if (!isLoading && error == null && recommendations.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) {
                      return RecommendationCard(
                        recommendation: recommendations[index],
                      );
                    },
                  ),

                // No Results
                if (!isLoading && error == null && recommendations.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'No restaurants found for $selectedCategory. Try another category!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
              ]

              // Stats Card (when no category selected)
              else ...[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEA580C), Color(0xFFDC2626)],
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}
