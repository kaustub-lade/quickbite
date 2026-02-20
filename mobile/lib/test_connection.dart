import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple test script to verify backend API connectivity
/// Run with: dart run lib/test_connection.dart
void main() async {
  print('🔍 Testing QuickBite Backend Connection...\n');
  
  // Test different base URLs
  final urls = [
    'http://localhost:3000',
    'http://127.0.0.1:3000',
    'http://10.0.2.2:3000', // Android emulator
  ];
  
  for (final baseUrl in urls) {
    print('Testing: $baseUrl');
    await testConnection(baseUrl);
    print('');
  }
}

Future<void> testConnection(String baseUrl) async {
  try {
    // Test 1: DB Connection
    print('  📡 Testing /api/db-test...');
    final dbResponse = await http
        .get(Uri.parse('$baseUrl/api/db-test'))
        .timeout(const Duration(seconds: 5));
    
    if (dbResponse.statusCode == 200) {
      final data = json.decode(dbResponse.body);
      print('  ✅ DB Status: ${data['status']}');
      if (data['restaurantCount'] != null) {
        print('  ✅ Restaurants: ${data['restaurantCount']}');
        print('  ✅ Platforms: ${data['platformCount']}');
        print('  ✅ Prices: ${data['priceCount']}');
      }
    } else {
      print('  ❌ DB Test Failed: ${dbResponse.statusCode}');
    }
    
    // Test 2: Recommendations API
    print('  📡 Testing /api/recommendations...');
    final recResponse = await http
        .get(Uri.parse('$baseUrl/api/recommendations?category=biryani'))
        .timeout(const Duration(seconds: 10));
    
    if (recResponse.statusCode == 200) {
      final data = json.decode(recResponse.body);
      print('  ✅ Recommendations: ${data['count']} found');
      print('  ✅ Category: ${data['category']}');
      
      if (data['recommendations'] != null && data['recommendations'].isNotEmpty) {
        final first = data['recommendations'][0];
        print('  ✅ First result: ${first['title']} - ₹${first['price']}');
      }
    } else {
      print('  ❌ Recommendations Failed: ${recResponse.statusCode}');
    }
    
    print('  ✅ Connection successful!');
  } catch (e) {
    print('  ❌ Connection failed: $e');
  }
}
