import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'customer',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'customer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isRestaurantOwner => role == 'restaurant_owner';
  bool get isCustomer => role == 'customer';
}

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  AuthProvider() {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('auth_token');
      final storedUserJson = prefs.getString('user_data');

      if (storedToken != null && storedUserJson != null) {
        _token = storedToken;
        _user = User.fromJson(json.decode(storedUserJson));
        notifyListeners();

        // Verify token is still valid
        await _verifyToken();
      }
    } catch (e) {
      debugPrint('Error loading stored auth: $e');
    }
  }

  Future<void> _verifyToken() async {
    if (_token == null) return;

    try {
      final response = await _apiService.getProfile(_token!);
      if (response['success'] != true) {
        await logout();
      }
    } catch (e) {
      debugPrint('Token verification failed: $e');
      await logout();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);

      if (response['success'] == true && response['data'] != null) {
        _token = response['data']['token'];
        _user = User.fromJson(response['data']['user']);

        // Store credentials
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_data', json.encode(_user!.toJson()));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['error'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String name, String email, String phone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.signup(name, email, phone, password);

      if (response['success'] == true && response['data'] != null) {
        _token = response['data']['token'];
        _user = User.fromJson(response['data']['user']);

        // Store credentials
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_data', json.encode(_user!.toJson()));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['error'] ?? 'Signup failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _error = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');

    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
