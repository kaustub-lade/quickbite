class Order {
  final String id;
  final String orderNumber;
  final String restaurantName;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final DeliveryAddress deliveryAddress;
  final String platform;
  final String? specialInstructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.restaurantName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    required this.deliveryAddress,
    required this.platform,
    this.specialInstructions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      restaurantName: json['restaurantName'] as String,
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      paymentStatus: json['paymentStatus'] as String,
      paymentMethod: json['paymentMethod'] as String?,
      deliveryAddress: DeliveryAddress.fromJson(json['deliveryAddress'] as Map<String, dynamic>),
      platform: json['platform'] as String,
      specialInstructions: json['specialInstructions'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String getStatusDisplay() {
    switch (status) {
      case 'pending':
        return 'Order Placed';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Being Prepared';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String getPaymentStatusDisplay() {
    switch (paymentStatus) {
      case 'pending':
        return 'Payment Pending';
      case 'completed':
        return 'Paid';
      case 'failed':
        return 'Payment Failed';
      default:
        return paymentStatus;
    }
  }
}

class OrderItem {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final bool isVeg;
  final String platform;

  OrderItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.isVeg,
    required this.platform,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      menuItemId: json['menuItemId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      isVeg: json['isVeg'] as bool,
      platform: json['platform'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'isVeg': isVeg,
      'platform': platform,
    };
  }

  double get totalPrice => price * quantity;
}

class DeliveryAddress {
  final String fullAddress;
  final String? landmark;
  final String city;
  final String pincode;
  final String phone;

  DeliveryAddress({
    required this.fullAddress,
    this.landmark,
    required this.city,
    required this.pincode,
    required this.phone,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      fullAddress: json['fullAddress'] as String,
      landmark: json['landmark'] as String?,
      city: json['city'] as String,
      pincode: json['pincode'] as String,
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullAddress': fullAddress,
      'landmark': landmark,
      'city': city,
      'pincode': pincode,
      'phone': phone,
    };
  }
}
