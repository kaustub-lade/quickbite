import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:uni_links/uni_links.dart';
import '../screens/restaurant_detail_screen.dart';

class DeepLinkHandler {
  static final DeepLinkHandler _instance = DeepLinkHandler._internal();
  factory DeepLinkHandler() => _instance;
  DeepLinkHandler._internal();

  StreamSubscription? _sub;
  BuildContext? _context;

  // Initialize deep link handling
  void initialize(BuildContext context) {
    _context = context;
    _initUniLinks();
  }

  Future<void> _initUniLinks() async {
    try {
      // Get initial link if app was opened from a link
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }

      // Listen for links while app is running
      _sub = linkStream.listen((String? link) {
        if (link != null) {
          _handleDeepLink(link);
        }
      }, onError: (err) {
        debugPrint('Deep link error: $err');
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to get initial link: ${e.message}');
    }
  }

  void _handleDeepLink(String link) {
    if (_context == null) return;

    final uri = Uri.parse(link);
    
    // Handle different deep link patterns:
    // quickbite://restaurant/{id}
    // quickbite://dish/{id}?restaurant={restaurantId}
    // quickbite://share/restaurant/{id}
    // quickbite://referral/{code}

    debugPrint('Handling deep link: $link');

    if (uri.scheme == 'quickbite' || uri.host == 'quickbite.app') {
      final pathSegments = uri.pathSegments;

      if (pathSegments.isEmpty) return;

      switch (pathSegments[0]) {
        case 'restaurant':
          if (pathSegments.length > 1) {
            _navigateToRestaurant(pathSegments[1]);
          }
          break;

        case 'dish':
          if (pathSegments.length > 1) {
            final restaurantId = uri.queryParameters['restaurant'];
            _navigateToDish(pathSegments[1], restaurantId);
          }
          break;

        case 'share':
          if (pathSegments.length > 2 && pathSegments[1] == 'restaurant') {
            _navigateToRestaurant(pathSegments[2]);
          }
          break;

        case 'referral':
          if (pathSegments.length > 1) {
            _handleReferral(pathSegments[1]);
          }
          break;

        default:
          debugPrint('Unknown deep link path: ${pathSegments[0]}');
      }
    }
  }

  void _navigateToRestaurant(String restaurantId) {
    if (_context == null) return;

    Navigator.of(_context!).push(
      MaterialPageRoute(
        builder: (context) => RestaurantDetailScreen(
          restaurantId: restaurantId,
        ),
      ),
    );
  }

  void _navigateToDish(String dishId, String? restaurantId) {
    if (_context == null) return;

    // If we have restaurant ID, navigate to restaurant and scroll to dish
    if (restaurantId != null) {
      Navigator.of(_context!).push(
        MaterialPageRoute(
          builder: (context) => RestaurantDetailScreen(
            restaurantId: restaurantId,
            highlightItemId: dishId,
          ),
        ),
      );
    } else {
      // Show a message that we need restaurant context
      ScaffoldMessenger.of(_context!).showSnackBar(
        const SnackBar(
          content: Text('Restaurant information not available'),
        ),
      );
    }
  }

  void _handleReferral(String code) {
    if (_context == null) return;

    // Store referral code (you can implement this in your auth system)
    debugPrint('Referral code: $code');
    
    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        content: Text('Referral code applied: $code'),
        backgroundColor: Colors.green,
      ),
    );

    // TODO: Save referral code to user profile or SharedPreferences
  }

  // Generate shareable link for restaurant
  static String generateRestaurantLink(String restaurantId, String restaurantName) {
    return 'quickbite://restaurant/$restaurantId';
  }

  // Generate shareable link for dish
  static String generateDishLink(String dishId, String restaurantId, String dishName) {
    return 'quickbite://dish/$dishId?restaurant=$restaurantId';
  }

  // Generate referral link
  static String generateReferralLink(String userId, String referralCode) {
    return 'quickbite://referral/$referralCode';
  }

  // Universal link format (for web and social sharing)
  static String generateWebLink(String type, String id) {
    return 'https://quickbite.app/$type/$id';
  }

  void dispose() {
    _sub?.cancel();
  }
}
