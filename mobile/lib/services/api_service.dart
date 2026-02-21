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
}
