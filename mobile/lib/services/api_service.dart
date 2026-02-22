import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/recommendation.dart';
import '../models/restaurant.dart';

class ApiService {
  // Read API URL from .env file
  // During development: http://localhost:3000
  // In production APK: https://quickbite-c016.onrender.com
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
  
  Future<RecommendationsResponse> getRecommendations(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recommendations?category=$category'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return RecommendationsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/db-test'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Connection test failed');
      }
    } catch (e) {
      throw Exception('Cannot connect to backend: $e');
    }
  }

  Future<Map<String, dynamic>> getMenu(String restaurantId, {String? category, bool? isVeg}) async {
    try {
      var uri = Uri.parse('$baseUrl/api/menu/$restaurantId');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (category != null && category != 'All') {
        queryParams['category'] = category;
      }
      if (isVeg != null && isVeg) {
        queryParams['isVeg'] = 'true';
      }
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load menu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch menu: $e');
    }
  }

  Future<Map<String, dynamic>> getPriceComparison(String restaurantId, {String? itemName}) async {
    try {
      var uri = Uri.parse('$baseUrl/api/menu/price-comparison');
      
      // Add query parameters
      final queryParams = <String, String>{'restaurantId': restaurantId};
      if (itemName != null) {
        queryParams['itemName'] = itemName;
      }
      
      uri = uri.replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load price comparison: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch price comparison: $e');
    }
  }

  Future<List<dynamic>> getPopularRestaurants() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/restaurants/popular'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['restaurants'] ?? [];
      } else {
        throw Exception('Failed to load popular restaurants: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch popular restaurants: $e');
    }
  }

  Future<List<dynamic>> getTrendingItems() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/menu/trending'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['items'] ?? [];
      } else {
        throw Exception('Failed to load trending items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch trending items: $e');
    }
  }

  Future<List<dynamic>> getBestDeals({int limit = 15}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/menu/best-deals?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['deals'] ?? [];
      } else {
        throw Exception('Failed to load best deals: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch best deals: $e');
    }
  }

  Future<Map<String, dynamic>> getRestaurantStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/restaurants/stats'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['stats'] ?? {};
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch stats: $e');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<Map<String, dynamic>> signup(String name, String email, String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  // Order APIs
  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to place order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }

  Future<List<dynamic>> getUserOrders(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['orders'] as List;
      } else {
        throw Exception('Failed to fetch orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/$orderId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['order'];
      } else {
        throw Exception('Failed to fetch order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  // Address Management APIs
  Future<List<dynamic>> getSavedAddresses(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/addresses?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['addresses'] as List;
      } else {
        throw Exception('Failed to fetch addresses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch addresses: $e');
    }
  }

  Future<Map<String, dynamic>> saveAddress(Map<String, dynamic> addressData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/addresses'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(addressData),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to save address');
      }
    } catch (e) {
      throw Exception('Failed to save address: $e');
    }
  }

  Future<Map<String, dynamic>> updateAddress(String addressId, Map<String, dynamic> addressData) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/addresses'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'addressId': addressId,
          ...addressData,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  Future<Map<String, dynamic>> deleteAddress(String addressId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/addresses?addressId=$addressId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete address: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }

  // Payment APIs
  Future<Map<String, dynamic>> createPaymentOrder({
    required double amount,
    String currency = 'INR',
    String? orderId,
    String? receipt,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/payment/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount,
          'currency': currency,
          'orderId': orderId,
          'receipt': receipt,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to create payment order');
      }
    } catch (e) {
      throw Exception('Failed to create payment order: $e');
    }
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String orderId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/payment/verify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
          'orderId': orderId,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Payment verification failed');
      }
    } catch (e) {
      throw Exception('Failed to verify payment: $e');
    }
  }

  // Get restaurants by platform
  Future<List<dynamic>> getRestaurantsByPlatform({
    required String platform,
    int limit = 20,
    String? cuisine,
  }) async {
    try {
      var queryParams = 'platform=$platform&limit=$limit';
      if (cuisine != null) {
        queryParams += '&cuisine=$cuisine';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/restaurants/by-platform?$queryParams'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['restaurants'] ?? [];
      } else {
        throw Exception('Failed to load restaurants: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get restaurants by platform: $e');
    }
  }

  // Get autocomplete suggestions
  Future<List<dynamic>> getAutocompleteSuggestions(String query, {int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/search/autocomplete?q=$query&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['suggestions'] ?? [];
      } else {
        throw Exception('Failed to load suggestions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get autocomplete suggestions: $e');
    }
  }

  // Advanced search with filters
  Future<Map<String, dynamic>> advancedSearch({
    String? query,
    double? minRating,
    int? maxPrice,
    bool? isVeg,
    String? platform,
    String? cuisine,
    int? maxDeliveryTime,
    String sortBy = 'relevance',
    int limit = 50,
  }) async {
    try {
      var queryParams = 'limit=$limit&sortBy=$sortBy';
      
      if (query != null) queryParams += '&q=$query';
      if (minRating != null) queryParams += '&minRating=$minRating';
      if (maxPrice != null) queryParams += '&maxPrice=$maxPrice';
      if (isVeg != null) queryParams += '&isVeg=$isVeg';
      if (platform != null) queryParams += '&platform=$platform';
      if (cuisine != null) queryParams += '&cuisine=$cuisine';
      if (maxDeliveryTime != null) queryParams += '&maxDeliveryTime=$maxDeliveryTime';

      final response = await http.get(
        Uri.parse('$baseUrl/api/search/advanced?$queryParams'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to perform advanced search: $e');
    }
  }

  // Admin Analytics - Get order trends
  Future<Map<String, dynamic>> getOrderTrends({
    int days = 30,
    String groupBy = 'day',
    String? token,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/analytics/order-trends?days=$days&groupBy=$groupBy'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load order trends: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get order trends: $e');
    }
  }

  // Admin Analytics - Get popular items
  Future<Map<String, dynamic>> getPopularItems({
    int limit = 20,
    int days = 30,
    String? token,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/analytics/popular-items?limit=$limit&days=$days'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load popular items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get popular items: $e');
    }
  }

  // Restaurant Owner - Get owned restaurants
  Future<List<dynamic>> getOwnerRestaurants(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/owner/restaurants'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['restaurants'] ?? [];
      } else {
        throw Exception('Failed to load restaurants: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get owner restaurants: $e');
    }
  }

  // Restaurant Owner - Get orders for restaurant
  Future<Map<String, dynamic>> getOwnerOrders({
    required String token,
    String? restaurantId,
    String? status,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      var queryParams = 'page=$page&limit=$limit';
      if (restaurantId != null) queryParams += '&restaurantId=$restaurantId';
      if (status != null) queryParams += '&status=$status';

      final response = await http.get(
        Uri.parse('$baseUrl/api/owner/orders?$queryParams'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get owner orders: $e');
    }
  }

  // Restaurant Owner - Update order status
  Future<Map<String, dynamic>> updateOrderStatus({
    required String token,
    required String orderId,
    required String status,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/owner/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'orderId': orderId,
          'status': status,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update order status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Favorites - Get user's favorites
  Future<Map<String, dynamic>> getFavorites({
    required String token,
    String? type, // 'restaurant' or 'dish' or null for all
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/api/favorites');
      if (type != null) {
        uri = Uri.parse('$baseUrl/api/favorites?type=$type');
      }

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load favorites: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get favorites: $e');
    }
  }

  // Favorites - Add to favorites
  Future<Map<String, dynamic>> addFavorite({
    required String token,
    required String itemType, // 'restaurant' or 'dish'
    required String itemId,
    required String itemName,
    String? itemImage,
    String? restaurantId, // Required for dishes
    String? restaurantName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/favorites'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'itemType': itemType,
          'itemId': itemId,
          'itemName': itemName,
          'itemImage': itemImage,
          'restaurantId': restaurantId,
          'restaurantName': restaurantName,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 409) {
        // Already favorited
        return json.decode(response.body);
      } else {
        throw Exception('Failed to add favorite: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  // Favorites - Remove from favorites
  Future<Map<String, dynamic>> removeFavorite({
    required String token,
    String? favoriteId,
    String? itemType,
    String? itemId,
  }) async {
    try {
      String queryParams = '';
      if (favoriteId != null) {
        queryParams = 'id=$favoriteId';
      } else if (itemType != null && itemId != null) {
        queryParams = 'itemType=$itemType&itemId=$itemId';
      } else {
        throw Exception('Provide either favoriteId or both itemType and itemId');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/favorites?$queryParams'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return {'success': false, 'error': 'Favorite not found'};
      } else {
        throw Exception('Failed to remove favorite: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }

  // Commission APIs - Admin only
  Future<Map<String, dynamic>> getCommissionReports({
    required String token,
    DateTime? startDate,
    DateTime? endDate,
    String? restaurantId,
    String? status,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      if (restaurantId != null) {
        queryParams['restaurantId'] = restaurantId;
      }
      if (status != null) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('$baseUrl/api/admin/commission').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch commission reports: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch commission reports: $e');
    }
  }

  Future<Map<String, dynamic>> updateCommissionStatus({
    required String token,
    required String orderId,
    required String type,
    required String status,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/admin/commission'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'orderId': orderId,
          'type': type,
          'status': status,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update commission status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update commission status: $e');
    }
  }

  // Order Tracking APIs
  Future<Map<String, dynamic>> getOrderTracking({
    required String token,
    required String orderId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/tracking?orderId=$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch order tracking: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch order tracking: $e');
    }
  }

  // Google Sign-In API
  Future<Map<String, dynamic>> googleSignIn({
    required String googleId,
    required String email,
    required String name,
    String? photoUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'googleId': googleId,
          'email': email,
          'name': name,
          'photoUrl': photoUrl,
        }),
      ).timeout(const Duration(seconds: 10));

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  // Coupon APIs
  Future<Map<String, dynamic>> validateCoupon({
    required String token,
    required String code,
    required double orderAmount,
    String? restaurantId,
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/coupons/validate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'code': code,
          'orderAmount': orderAmount,
          'restaurantId': restaurantId,
          'items': items,
        }),
      ).timeout(const Duration(seconds: 10));

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to validate coupon: $e');
    }
  }

  // Gift Card APIs
  Future<Map<String, dynamic>> checkGiftCard({
    required String token,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/gift-cards/check'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'code': code,
        }),
      ).timeout(const Duration(seconds: 10));

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to check gift card: $e');
    }
  }

  Future<Map<String, dynamic>> redeemGiftCard({
    required String token,
    required String code,
    required double amount,
    required String orderId,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/gift-cards/check'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'code': code,
          'amount': amount,
          'orderId': orderId,
        }),
      ).timeout(const Duration(seconds: 10));

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to redeem gift card: $e');
    }
  }

  // Location update API
  Future<Map<String, dynamic>> updateUserLocation({
    required String token,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/auth/location'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
        }),
      ).timeout(const Duration(seconds: 10));

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }
}

