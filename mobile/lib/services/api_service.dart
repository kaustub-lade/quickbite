import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recommendation.dart';

class ApiService {
  // For local development - update this based on your setup
  // Android emulator: http://10.0.2.2:3000
  // iOS simulator: http://localhost:3000
  // Physical device: http://YOUR_IP:3000
  static const String baseUrl = 'http://10.0.2.2:3000'; // Default for Android emulator
  
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
}
