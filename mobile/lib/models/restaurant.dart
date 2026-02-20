class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final String location;
  final double rating;
  final int deliveryTime;
  final String imageUrl;
  final bool isPureVeg;
  final double costForTwo;
  final List<String> offers;
  final String description;
  
  Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.location,
    required this.rating,
    required this.deliveryTime,
    required this.imageUrl,
    this.isPureVeg = false,
    required this.costForTwo,
    this.offers = const [],
    this.description = '',
  });
  
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      cuisine: json['cuisine'] ?? '',
      location: json['location'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      deliveryTime: json['deliveryTime'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      isPureVeg: json['isPureVeg'] ?? false,
      costForTwo: (json['costForTwo'] ?? 0).toDouble(),
      offers: List<String>.from(json['offers'] ?? []),
      description: json['description'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cuisine': cuisine,
      'location': location,
      'rating': rating,
      'deliveryTime': deliveryTime,
      'imageUrl': imageUrl,
      'isPureVeg': isPureVeg,
      'costForTwo': costForTwo,
      'offers': offers,
      'description': description,
    };
  }
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool isVeg;
  final bool isBestseller;
  final double rating;
  final int ratingsCount;
  final String category;
  
  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isVeg = true,
    this.isBestseller = false,
    this.rating = 0.0,
    this.ratingsCount = 0,
    required this.category,
  });
  
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      isVeg: json['isVeg'] ?? true,
      isBestseller: json['isBestseller'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
      ratingsCount: json['ratingsCount'] ?? 0,
      category: json['category'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'isVeg': isVeg,
      'isBestseller': isBestseller,
      'rating': rating,
      'ratingsCount': ratingsCount,
      'category': category,
    };
  }
}

class CartItem {
  final MenuItem menuItem;
  int quantity;
  
  CartItem({
    required this.menuItem,
    this.quantity = 1,
  });
  
  double get totalPrice => menuItem.price * quantity;
}
