import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/auth_provider.dart';
import 'restaurant_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      await favoritesProvider.loadFavorites(authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFEA580C),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFEA580C),
          tabs: const [
            Tab(text: 'Restaurants'),
            Tab(text: 'Dishes'),
          ],
        ),
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, _) {
          if (favoritesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (favoritesProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading favorites',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    favoritesProvider.error!,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadFavorites,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildRestaurantsList(context, favoritesProvider),
              _buildDishesList(context, favoritesProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRestaurantsList(BuildContext context, FavoritesProvider provider) {
    final restaurants = provider.restaurantFavorites;

    if (restaurants.isEmpty) {
      return _buildEmptyState(
        icon: Icons.restaurant,
        title: 'No Favorite Restaurants',
        subtitle: 'Tap the heart icon on restaurants to save them here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final favorite = restaurants[index];
          return _buildRestaurantCard(context, favorite, provider);
        },
      ),
    );
  }

  Widget _buildDishesList(BuildContext context, FavoritesProvider provider) {
    final dishes = provider.dishFavorites;

    if (dishes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.fastfood,
        title: 'No Favorite Dishes',
        subtitle: 'Tap the heart icon on dishes to save them here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dishes.length,
        itemBuilder: (context, index) {
          final favorite = dishes[index];
          return _buildDishCard(context, favorite, provider);
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              subtitle,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(BuildContext context, Favorite favorite, FavoritesProvider provider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: favorite.itemImage != null
              ? Image.network(
                  favorite.itemImage!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.restaurant),
                  ),
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.restaurant),
                ),
        ),
        title: Text(
          favorite.itemName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Added ${_formatDate(favorite.createdAt)}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.favorite, color: Color(0xFFEA580C)),
              onPressed: () async {
                final confirmed = await _confirmRemove(context, favorite.itemName);
                if (confirmed && authProvider.token != null) {
                  await provider.removeFavorite(
                    token: authProvider.token!,
                    favoriteId: favorite.id,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Removed from favorites')),
                    );
                  }
                }
              },
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          // Navigate to restaurant detail
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RestaurantDetailScreen(
                restaurantId: favorite.itemId,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDishCard(BuildContext context, Favorite favorite, FavoritesProvider provider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: favorite.itemImage != null
              ? Image.network(
                  favorite.itemImage!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.fastfood),
                  ),
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.fastfood),
                ),
        ),
        title: Text(
          favorite.itemName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (favorite.restaurantName != null)
              Text(
                favorite.restaurantName!,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            Text(
              'Added ${_formatDate(favorite.createdAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.favorite, color: Color(0xFFEA580C)),
              onPressed: () async {
                final confirmed = await _confirmRemove(context, favorite.itemName);
                if (confirmed && authProvider.token != null) {
                  await provider.removeFavorite(
                    token: authProvider.token!,
                    favoriteId: favorite.id,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Removed from favorites')),
                    );
                  }
                }
              },
            ),
            if (favorite.restaurantId != null) const Icon(Icons.chevron_right),
          ],
        ),
        onTap: favorite.restaurantId != null
            ? () {
                // Navigate to restaurant detail
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantDetailScreen(
                      restaurantId: favorite.restaurantId!,
                    ),
                  ),
                );
              }
            : null,
      ),
    );
  }

  Future<bool> _confirmRemove(BuildContext context, String itemName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove from Favorites?'),
            content: Text('Remove "$itemName" from your favorites?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Remove'),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
  }
}
