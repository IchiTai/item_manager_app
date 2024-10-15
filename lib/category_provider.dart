import 'package:flutter/material.dart';
import 'item_model.dart';

class CategoryProvider with ChangeNotifier {
  Map<String, List<Item>> _categories = {};

  Map<String, List<Item>> get categories => _categories;

  void addCategory(String category) {
    if (!_categories.containsKey(category)) {
      _categories[category] = [];
      notifyListeners();
    }
  }

  void addItem(String category, String itemName, int quantity) {
    if (_categories.containsKey(category)) {
      _categories[category]?.add(Item(itemName, quantity));
      notifyListeners();
    }
  }

  void removeCategory(String category) {
    _categories.remove(category);
    notifyListeners();
  }

  void updateItemQuantity(String category, String itemName, int newQuantity) {
    final item =
        _categories[category]?.firstWhere((item) => item.name == itemName);
    if (item != null) {
      item.quantity = newQuantity;
      notifyListeners();
    }
  }

  void removeItem(String category, String itemName) {
    _categories[category]?.removeWhere((item) => item.name == itemName);
    notifyListeners();
  }
}
