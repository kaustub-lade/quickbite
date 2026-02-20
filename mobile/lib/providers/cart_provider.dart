import 'package:flutter/foundation.dart';
import '../models/restaurant.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  String? _restaurantId;
  String? _restaurantName;
  
  Map<String, CartItem> get items => {..._items};
  
  int get itemCount => _items.length;
  
  int get totalQuantity {
    int total = 0;
    _items.forEach((key, item) {
      total += item.quantity;
    });
    return total;
  }
  
  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.totalPrice;
    });
    return total;
  }
  
  String? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;
  
  bool get isEmpty => _items.isEmpty;
  
  void addItem(MenuItem menuItem, String restaurantId, String restaurantName) {
    // Check if cart has items from different restaurant
    if (_restaurantId != null && _restaurantId != restaurantId) {
      // Show warning or clear cart
      return;
    }
    
    _restaurantId = restaurantId;
    _restaurantName = restaurantName;
    
    if (_items.containsKey(menuItem.id)) {
      _items[menuItem.id]!.quantity++;
    } else {
      _items[menuItem.id] = CartItem(menuItem: menuItem);
    }
    notifyListeners();
  }
  
  void removeItem(String menuItemId) {
    if (!_items.containsKey(menuItemId)) return;
    
    if (_items[menuItemId]!.quantity > 1) {
      _items[menuItemId]!.quantity--;
    } else {
      _items.remove(menuItemId);
    }
    
    if (_items.isEmpty) {
      _restaurantId = null;
      _restaurantName = null;
    }
    
    notifyListeners();
  }
  
  void removeItemCompletely(String menuItemId) {
    _items.remove(menuItemId);
    
    if (_items.isEmpty) {
      _restaurantId = null;
      _restaurantName = null;
    }
    
    notifyListeners();
  }
  
  void clear() {
    _items.clear();
    _restaurantId = null;
    _restaurantName = null;
    notifyListeners();
  }
  
  int getItemQuantity(String menuItemId) {
    return _items[menuItemId]?.quantity ?? 0;
  }
  
  bool isFromDifferentRestaurant(String restaurantId) {
    return _restaurantId != null && _restaurantId != restaurantId;
  }
}
