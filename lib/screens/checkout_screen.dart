import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // [PENTING] Untuk Formatter
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/cart_provider.dart';
import '../widgets/digital_receipt.dart';
import '../utils/currency_formatter.dart'; // [PENTING] Import file formatter

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _payController = TextEditingController();
  double _receivedAmount = 0.0;
  double _changeAmount = 0.0;

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _payController.dispose();
    super.dispose();
  }

  // LOGIKA HITUNG KEMBALIAN
  void _calculateChange(String value, double totalAmount) {
    setState(() {
      // [PENTING] Hapus titik sebelum dihitung (50.000 -> 50000)
      String cleanValue = value.replaceAll('.', '');

      _receivedAmount = double.tryParse(cleanValue) ?? 0.0;
      _changeAmount = _receivedAmount - totalAmount;
    });
  }

  // FUNGSI LOAD GAMBAR PINTAR (Internet/Local/File)
  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      return FileImage(File(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final totalAmount = cart.totalPrice;
    final theme = Theme.of(context);
    final orangeColor = theme.primaryColor;

    if (cart.items.isEmpty) {
      Future.delayed(Duration.zero, () => Navigator.pop(context));
      return const SizedBox();
    }

    final bool isPaymentSufficient = _receivedAmount >= totalAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ringkasan Pesanan"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 1. LIST PESANAN
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) {
                var key = cart.items.keys.elementAt(i);
                var item = cart.items[key]!;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[800],
                      image: DecorationImage(
                        image: _getImageProvider(item.product.imagePath),
                        fit: BoxFit.cover,
                        onError: (_, __) {},
                      ),
                    ),
                  ),
                  title: Text(
                    item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${item.quantity} x ${currencyFormatter.format(item.product.price)}",
                  ),
                  trailing: Text(
                    currencyFormatter.format(item.subtotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. PANEL PEMBAYARAN
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(blurRadius: 30, color: Colors.black.withOpacity(0.8)),
              ],
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Tagihan",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      Text(
                        currencyFormatter.format(totalAmount),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: orangeColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // INPUT PEMBAYARAN (DENGAN FORMATTER)
                  TextField(
                    controller: _payController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),

                    // [BARU] Tambahkan Formatter di sini
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CurrencyInputFormatter(),
                    ],

                    // Logic realtime calculation
                    onChanged: (val) => _calculateChange(val, totalAmount),

                    decoration: InputDecoration(
                      labelText: "Uang Diterima",
                      prefixText: "Rp ",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _payController.clear();
                          _calculateChange('', totalAmount);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info Kembalian
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPaymentSufficient
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isPaymentSufficient ? "Kembalian:" : "Kurang Bayar:",
                          style: TextStyle(
                            color: isPaymentSufficient
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currencyFormatter.format(_changeAmount.abs()),
                          style: TextStyle(
                            fontSize: 18,
                            color: isPaymentSufficient
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Proses
                  ElevatedButton.icon(
                    onPressed: isPaymentSufficient
                        ? () async {
                            bool? isDone = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) => DigitalReceipt(
                                items: cart.items,
                                totalAmount: totalAmount,
                                receivedAmount: _receivedAmount,
                                changeAmount: _changeAmount,
                                transactionTime: DateTime.now(),
                              ),
                            );

                            if (isDone == true) {
                              if (!mounted) return;
                              cart.clearCart();
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Transaksi Berhasil!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPaymentSufficient
                          ? orangeColor
                          : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    icon: const Icon(Icons.print, size: 28),
                    label: const Text(
                      "PROSES & CETAK",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
