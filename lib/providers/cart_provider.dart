import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  List<CartProduct> _items = [];
  double _total = 0.0;
  double _discountedTotal = 0.0;
  int _totalQuantity = 0;

  List<CartProduct> get items => _items;
  double get total => _total;
  double get discountedTotal => _discountedTotal;
  int get totalQuantity => _totalQuantity;

  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.id == product.id);
    
    if (existingIndex != -1) {
      // Update existing item
      final existing = _items[existingIndex];
      final newQuantity = existing.quantity + quantity;
      final discountedPrice = product.price * (1 - product.discountPercentage / 100);
      
      _items[existingIndex] = CartProduct(
        id: existing.id,
        title: existing.title,
        price: existing.price,
        quantity: newQuantity,
        total: existing.price * newQuantity,
        discountPercentage: existing.discountPercentage,
        discountedTotal: discountedPrice * newQuantity,
        thumbnail: existing.thumbnail,
      );
    } else {
      // Add new item
      final discountedPrice = product.price * (1 - product.discountPercentage / 100);
      _items.add(CartProduct(
        id: product.id,
        title: product.title,
        price: product.price,
        quantity: quantity,
        total: product.price * quantity,
        discountPercentage: product.discountPercentage,
        discountedTotal: discountedPrice * quantity,
        thumbnail: product.thumbnail,
      ));
    }
    _updateTotals();
    notifyListeners();
  }

  void updateQuantity(int productId, int newQuantity) {
    final index = _items.indexWhere((item) => item.id == productId);
    if (index == -1) return;
    
    if (newQuantity < 1) {
      _items.removeAt(index);
    } else {
      final item = _items[index];
      final discountedPrice = item.price * (1 - item.discountPercentage / 100);
      _items[index] = CartProduct(
        id: item.id,
        title: item.title,
        price: item.price,
        quantity: newQuantity,
        total: item.price * newQuantity,
        discountPercentage: item.discountPercentage,
        discountedTotal: discountedPrice * newQuantity,
        thumbnail: item.thumbnail,
      );
    }
    _updateTotals();
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.removeWhere((item) => item.id == productId);
    _updateTotals();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _updateTotals();
    notifyListeners();
  }

  void _updateTotals() {
    _total = _items.fold(0.0, (sum, item) => sum + item.total);
    _discountedTotal = _items.fold(0.0, (sum, item) => sum + item.discountedTotal);
    _totalQuantity = _items.fold(0, (sum, item) => sum + item.quantity);
  }
}