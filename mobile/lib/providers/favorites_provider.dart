import 'package:flutter/material.dart';
import '../services/api_service.dart';

class Favorite {
  final String id;
  final String userId;
  final String itemType; // 'restaurant' or 'dish'
  final String itemId;
  final String itemName;
  final String? itemImage;
  final String? restaurantId;
  final String? restaurantName;
  final DateTime createdAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.itemType,
    required this.itemId,
    required this.itemName,
    this.itemImage,
    this.restaurantId,
    this.restaurantName,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      itemType: json['itemType'] as String,
      itemId: json['itemId'] as String,
      itemName: json['itemName'] as String,
      itemImage: json['itemImage'] as String?,
      restaurantId: json['restaurantId'] as String?,
      restaurantName: json['restaurantName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class FavoritesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Favorite> _favorites = [];
  bool _isLoading = false;
  String? _error;

  List<Favorite> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Favorite> get restaurantFavorites =>
      _favorites.where((f) => f.itemType == 'restaurant').toList();
  
  List<Favorite> get dishFavorites =>
      _favorites.where((f) => f.itemType == 'dish').toList();

  // Check if an item is favorited
  bool isFavorited(String itemType, String itemId) {
    return _favorites.any((f) => f.itemType == itemType && f.itemId == itemId);
  }

  // Load favorites from API
  Future<void> loadFavorites(String token, {String? type}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getFavorites(token: token, type: type);
      
      if (response['success'] == true) {
        _favorites = (response['favorites'] as List)
            .map((json) => Favorite.fromJson(json))
            .toList();
        _error = null;
      } else {
        _error = response['error'] ?? 'Failed to load favorites';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add to favorites
  Future<bool> addFavorite({
    required String token,
    required String itemType,
    required String itemId,
    required String itemName,
    String? itemImage,
    String? restaurantId,
    String? restaurantName,
  }) async {
    try {
      final response = await _apiService.addFavorite(
        token: token,
        itemType: itemType,
        itemId: itemId,
        itemName: itemName,
        itemImage: itemImage,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
      );

      if (response['success'] == true) {
        // Add to local list
        final newFavorite = Favorite.fromJson(response['favorite']);
        _favorites.add(newFavorite);
        notifyListeners();
        return true;
      } else if (response['error']?.contains('already in favorites') == true) {
        // Already favorited, reload to sync
        await loadFavorites(token);
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Remove from favorites
  Future<bool> removeFavorite({
    required String token,
    String? favoriteId,
    String? itemType,
    String? itemId,
  }) async {
    try {
      final response = await _apiService.removeFavorite(
        token: token,
        favoriteId: favoriteId,
        itemType: itemType,
        itemId: itemId,
      );

      if (response['success'] == true) {
        // Remove from local list
        if (favoriteId != null) {
          _favorites.removeWhere((f) => f.id == favoriteId);
        } else if (itemType != null && itemId != null) {
          _favorites.removeWhere((f) => f.itemType == itemType && f.itemId == itemId);
        }
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Toggle favorite (add if not favorited, remove if favorited)
  Future<bool> toggleFavorite({
    required String token,
    required String itemType,
    required String itemId,
    required String itemName,
    String? itemImage,
    String? restaurantId,
    String? restaurantName,
  }) async {
    if (isFavorited(itemType, itemId)) {
      return await removeFavorite(
        token: token,
        itemType: itemType,
        itemId: itemId,
      );
    } else {
      return await addFavorite(
        token: token,
        itemType: itemType,
        itemId: itemId,
        itemName: itemName,
        itemImage: itemImage,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
      );
    }
  }

  // Clear favorites (e.g., on logout)
  void clearFavorites() {
    _favorites = [];
    _error = null;
    notifyListeners();
  }
}
