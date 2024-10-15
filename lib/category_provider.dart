import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'item_model.dart';
import 'package:flutter/foundation.dart';

class CategoryProvider with ChangeNotifier {
  Map<String, List<Item>> _categories = {};

  Map<String, List<Item>> get categories => _categories;

  Future<void> saveCategories() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> jsonCategories = _categories.map((key, value) {
      return MapEntry(key, value.map((item) => item.toJson()).toList());
    });

    prefs.setString('categories', jsonEncode(jsonCategories));
  }

  Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? categoriesString = prefs.getString('categories');
    if (categoriesString != null) {
      final Map<String, dynamic> decodedCategories =
          jsonDecode(categoriesString);

      _categories = decodedCategories.map((key, value) {
        return MapEntry(
            key, (value as List).map((item) => Item.fromJson(item)).toList());
      });
      notifyListeners();
    }
  }

  void addCategory(String category) {
    if (!_categories.containsKey(category)) {
      _categories[category] = [];
      saveCategories();
      notifyListeners();
    }
  }

  void addItem(String category, String itemName, int quantity) {
    if (_categories.containsKey(category)) {
      _categories[category]?.add(Item(itemName, quantity));
      saveCategories();
      notifyListeners();
    }
  }

  void removeCategory(String category) {
    _categories.remove(category);
    saveCategories();
    notifyListeners();
  }

  void removeItem(String category, String itemName) {
    _categories[category]?.removeWhere((item) => item.name == itemName);
    saveCategories();
    notifyListeners();
  }

  void updateItemQuantity(String category, String itemName, int newQuantity) {
    final item =
        _categories[category]?.firstWhere((item) => item.name == itemName);
    if (item != null) {
      item.quantity = newQuantity;
      saveCategories();
      notifyListeners();
    }
  }
}
