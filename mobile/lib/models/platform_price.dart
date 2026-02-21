// Model for platform-specific pricing data
class PlatformPrice {
  final String platform;
  final String platformId;
  final double price;
  final int deliveryTime;
  final bool isBestDeal;
  final double savings;

  PlatformPrice({
    required this.platform,
    required this.platformId,
    required this.price,
    required this.deliveryTime,
    this.isBestDeal = false,
    this.savings = 0,
  });

  factory PlatformPrice.fromJson(Map<String, dynamic> json) {
    return PlatformPrice(
      platform: json['platform'] as String? ?? '',
      platformId: json['platformId'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      deliveryTime: json['deliveryTime'] as int? ?? 0,
      isBestDeal: json['isBestDeal'] as bool? ?? false,
      savings: (json['savings'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'platformId': platformId,
      'price': price,
      'deliveryTime': deliveryTime,
      'isBestDeal': isBestDeal,
      'savings': savings,
    };
  }
}

// Model for best deal information
class BestDeal {
  final String platform;
  final double price;
  final int deliveryTime;

  BestDeal({
    required this.platform,
    required this.price,
    required this.deliveryTime,
  });

  factory BestDeal.fromJson(Map<String, dynamic> json) {
    return BestDeal(
      platform: json['platform'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      deliveryTime: json['deliveryTime'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'price': price,
      'deliveryTime': deliveryTime,
    };
  }
}

// Enhanced MenuItem with platform pricing
class MenuItemWithPricing {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final String category;
  final bool isVeg;
  final String? imageUrl;
  final double? rating;
  final bool hasPlatformPricing;
  final List<PlatformPrice> platformPrices;
  final BestDeal? bestDeal;

  MenuItemWithPricing({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.category,
    required this.isVeg,
    this.imageUrl,
    this.rating,
    this.hasPlatformPricing = false,
    this.platformPrices = const [],
    this.bestDeal,
  });

  factory MenuItemWithPricing.fromJson(Map<String, dynamic> json) {
    final platformPricesList = json['platformPrices'] as List<dynamic>? ?? [];
    final bestDealData = json['bestDeal'] as Map<String, dynamic>?;

    return MenuItemWithPricing(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? '',
      isVeg: json['isVeg'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      hasPlatformPricing: json['hasPlatformPricing'] as bool? ?? false,
      platformPrices: platformPricesList
          .map((p) => PlatformPrice.fromJson(p as Map<String, dynamic>))
          .toList(),
      bestDeal: bestDealData != null ? BestDeal.fromJson(bestDealData) : null,
    );
  }

  // Helper to get maximum savings
  double get maxSavings {
    if (platformPrices.isEmpty) return 0;
    return platformPrices
        .map((p) => p.savings)
        .reduce((max, savings) => savings > max ? savings : max);
  }

  // Helper to get cheapest price
  double get cheapestPrice {
    if (platformPrices.isEmpty) return basePrice;
    return platformPrices
        .map((p) => p.price)
        .reduce((min, price) => price < min ? price : min);
  }

  // Helper to get most expensive price
  double get mostExpensivePrice {
    if (platformPrices.isEmpty) return basePrice;
    return platformPrices
        .map((p) => p.price)
        .reduce((max, price) => price > max ? price : max);
  }
}
