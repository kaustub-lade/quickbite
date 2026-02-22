import 'package:share_plus/share_plus.dart';
import 'deep_link_handler.dart';

class ShareUtils {
  // Share restaurant
  static Future<void> shareRestaurant({
    required String restaurantId,
    required String restaurantName,
    String? cuisine,
  }) async {
    final link = DeepLinkHandler.generateRestaurantLink(restaurantId, restaurantName);
    final webLink = DeepLinkHandler.generateWebLink('restaurant', restaurantId);
    
    final message = cuisine != null
        ? 'Check out $restaurantName on QuickBite! 🍽️\n$cuisine\n\nOpen in app: $link\nView online: $webLink'
        : 'Check out $restaurantName on QuickBite! 🍽️\n\nOpen in app: $link\nView online: $webLink';

    await Share.share(
      message,
      subject: 'Check out $restaurantName on QuickBite',
    );
  }

  // Share dish
  static Future<void> shareDish({
    required String dishId,
    required String dishName,
    required String restaurantId,
    required String restaurantName,
    double? price,
  }) async {
    final link = DeepLinkHandler.generateDishLink(dishId, restaurantId, dishName);
    final webLink = DeepLinkHandler.generateWebLink('dish', dishId);
    
    final priceText = price != null ? ' for just ₹${price.toStringAsFixed(0)}' : '';
    final message = 'Try $dishName from $restaurantName$priceText! 😋\n\n'
        'Open in app: $link\n'
        'View online: $webLink';

    await Share.share(
      message,
      subject: 'Check out $dishName on QuickBite',
    );
  }

  // Share referral code
  static Future<void> shareReferral({
    required String userId,
    required String referralCode,
    String? userName,
  }) async {
    final link = DeepLinkHandler.generateReferralLink(userId, referralCode);
    
    final name = userName ?? 'I';
    final message = '$name invited you to join QuickBite! 🎁\n\n'
        'Get exclusive deals and compare food prices across Swiggy, Zomato, and ONDC.\n\n'
        'Use my referral code: $referralCode\n'
        'Or click here: $link\n\n'
        'Download QuickBite now!';

    await Share.share(
      message,
      subject: 'Join QuickBite and save on food delivery!',
    );
  }

  // Share deal/offer
  static Future<void> shareDeal({
    required String title,
    required String description,
    String? deepLink,
  }) async {
    final message = '🔥 $title\n\n$description\n\n'
        '${deepLink != null ? 'Check it out: $deepLink\n\n' : ''}'
        'Download QuickBite to save on every meal!';

    await Share.share(
      message,
      subject: title,
    );
  }

  // Share savings achievement
  static Future<void> shareSavings({
    required double totalSaved,
    required int orderCount,
  }) async {
    final message = '💰 I saved ₹${totalSaved.toStringAsFixed(0)} '
        'on $orderCount orders with QuickBite!\n\n'
        'Compare prices across Swiggy, Zomato, and ONDC to save on every meal.\n\n'
        'Download QuickBite now! 🍽️';

    await Share.share(
      message,
      subject: 'I\'m saving big with QuickBite!',
    );
  }
}
