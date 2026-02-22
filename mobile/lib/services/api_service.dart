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
}
