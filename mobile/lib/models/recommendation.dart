class Recommendation {
  final String id;
  final String title;
  final String badge;
  final String badgeVariant;
  final int price;
  final int savings;
  final String platform;
  final int deliveryTime;
  final double rating;
  final String reason;
  final String cuisine;
  final String location;

  Recommendation({
    required this.id,
    required this.title,
    required this.badge,
    required this.badgeVariant,
    required this.price,
    required this.savings,
    required this.platform,
    required this.deliveryTime,
    required this.rating,
    required this.reason,
    required this.cuisine,
    required this.location,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      badge: json['badge'] ?? '',
      badgeVariant: json['badgeVariant'] ?? 'default',
      price: json['price'] ?? 0,
      savings: json['savings'] ?? 0,
      platform: json['platform'] ?? '',
      deliveryTime: json['deliveryTime'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      reason: json['reason'] ?? '',
      cuisine: json['cuisine'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'badge': badge,
      'badgeVariant': badgeVariant,
      'price': price,
      'savings': savings,
      'platform': platform,
      'deliveryTime': deliveryTime,
      'rating': rating,
      'reason': reason,
      'cuisine': cuisine,
      'location': location,
    };
  }
}

class RecommendationsResponse {
  final String category;
  final int count;
  final List<Recommendation> recommendations;

  RecommendationsResponse({
    required this.category,
    required this.count,
    required this.recommendations,
  });

  factory RecommendationsResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationsResponse(
      category: json['category'] ?? '',
      count: json['count'] ?? 0,
      recommendations: (json['recommendations'] as List?)
              ?.map((item) => Recommendation.fromJson(item))
              .toList() ??
          [],
    );
  }
}
