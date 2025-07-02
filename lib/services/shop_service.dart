import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class ShopItem {
  final String id;
  final String name;
  final double price;
  final String type; // iap/virtual
  ShopItem({required this.id, required this.name, required this.price, required this.type});

  factory ShopItem.fromJson(Map<String, dynamic> json) => ShopItem(
        id: json['id'],
        name: json['name'],
        price: (json['price'] as num).toDouble(),
        type: json['type'],
      );
}

class ShopService extends ChangeNotifier {
  final List<ShopItem> _items = [];
  List<ShopItem> get items => _items;

  Future<void> load() async {
    final str = await rootBundle.loadString('assets/shop_items.json');
    final list = jsonDecode(str) as List;
    _items.clear();
    _items.addAll(list.map((e) => ShopItem.fromJson(e)));
    notifyListeners();
  }
}