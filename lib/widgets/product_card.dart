import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItem = cart.items[product.id];
    final int quantity = cartItem?.quantity ?? 0;

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final theme = Theme.of(context);
    final orangeColor = theme.primaryColor;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. GAMBAR PRODUK (Logic Baru: Support Network, Asset, & File)
          Expanded(flex: 3, child: _buildImage(product.imagePath)),

          // 2. INFORMASI (Sama seperti sebelumnya)
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormatter.format(product.price),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: orangeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. KONTROL JUMLAH 
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: orangeColor.withOpacity(0.1),
              border: Border(
                top: BorderSide(color: orangeColor.withOpacity(0.2)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQtyButton(
                  icon: Icons.remove,
                  color: orangeColor,
                  onTap: quantity > 0
                      ? () => cart.removeItem(product.id!)
                      : null,
                ),
                Text(
                  '$quantity',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: quantity > 0 ? Colors.white : Colors.grey,
                  ),
                ),
                _buildQtyButton(
                  icon: Icons.add,
                  color: orangeColor,
                  onTap: () => cart.addItem(product),
                  isFilled: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // LOGIC PINTAR MEMILIH SUMBER GAMBAR
  Widget _buildImage(String path) {
    if (path.startsWith('http')) {
      // 1. Gambar dari Internet
      return Image.network(
        path,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _errorPlaceholder(),
      );
    } else if (path.startsWith('assets/')) {
      // 2. Gambar dari Aset Lokal (Laptop)
      return Image.asset(
        path,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _errorPlaceholder(),
      );
    } else {
      // 3. Gambar dari File HP (Galeri)
      return Image.file(
        File(path),
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _errorPlaceholder(),
      );
    }
  }

  Widget _errorPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.white54),
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    bool isFilled = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isFilled ? color : Colors.transparent,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, size: 20, color: isFilled ? Colors.black : color),
      ),
    );
  }
}
