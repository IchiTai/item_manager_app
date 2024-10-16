import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'item_model.dart';
import 'package:flutter/foundation.dart';

class CategoryProvider with ChangeNotifier {
  Map<String, List<Item>> _categories = {};
  List<String> _categoryOrder = [];

  Map<String, List<Item>> get categories => _categories;
  List<String> get categoryOrder => _categoryOrder;

  Future<void> saveCategories() async {
    final prefs = await SharedPreferences.getInstance();

    // カテゴリーとアイテムをJSON形式で保存
    Map<String, dynamic> jsonCategories = _categories.map((key, value) {
      return MapEntry(key, value.map((item) => item.toJson()).toList());
    });
    prefs.setString('categories', jsonEncode(jsonCategories));

    // カテゴリー順序を保存
    prefs.setStringList('categoryOrder', _categoryOrder);
  }

  Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();

    // 保存されたカテゴリーの復元
    final String? categoriesString = prefs.getString('categories');
    if (categoriesString != null) {
      final Map<String, dynamic> decodedCategories = jsonDecode(categoriesString);

      _categories = decodedCategories.map((key, value) {
        return MapEntry(key, (value as List).map((item) => Item.fromJson(item)).toList());
      });
    }

    // 保存されたカテゴリー順序の復元
    final List<String>? categoryOrder = prefs.getStringList('categoryOrder');
    if (categoryOrder != null) {
      _categoryOrder = categoryOrder;
    } else {
      _categoryOrder = _categories.keys.toList(); // 順序がなければデフォルトの順序
    }

    notifyListeners();
  }

  void reorderCategory(int oldIndex, int newIndex) {
  if (newIndex > oldIndex) {
    newIndex -= 1;  // リストをドラッグ＆ドロップしたときの新しいインデックスを調整
  }

  // 順番を変更する
  final String category = _categoryOrder.removeAt(oldIndex);
  _categoryOrder.insert(newIndex, category);

  // カテゴリー順の保存
  saveCategories();
  notifyListeners();
}

void reorderItem(String category, int oldIndex, int newIndex) {
  if (_categories.containsKey(category)) {
    final items = _categories[category];
    if (items != null) {
      // アイテムの順序を変更
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);

      // カテゴリーのデータを保存
      saveCategories();
      notifyListeners();
    }
  }
}

  void addCategory(String category) {
    if (!_categories.containsKey(category)) {
      _categories[category] = [];
      _categoryOrder.add(category); // 新しいカテゴリーを順序リストに追加
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
    _categoryOrder.remove(category); // 順序リストからも削除
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
