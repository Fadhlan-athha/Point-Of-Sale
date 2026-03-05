import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;
}

class CartProvider with ChangeNotifier {
  // Key: Product ID, Value: CartItem
  Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => _items;

  // Hitung Total Belanja
  double get totalPrice {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.subtotal;
    });
    return total;
  }

  // Tambah ke Keranjang
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id!,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id!,
        () => CartItem(product: product, quantity: 1),
      );
    }
    notifyListeners();
  }

  // Kurangi/Hapus Item
  void removeItem(int productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // Kosongkan Keranjang (Setelah Print/Bayar)
  void clearCart() {
    _items = {};
    notifyListeners();
  }
}
