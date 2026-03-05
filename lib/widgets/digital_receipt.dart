import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/cart_provider.dart';

class DigitalReceipt extends StatelessWidget {
  final Map<int, CartItem> items;
  final double totalAmount;
  final double receivedAmount;
  final double changeAmount;
  final DateTime transactionTime;

  const DigitalReceipt({
    super.key,
    required this.items,
    required this.totalAmount,
    required this.receivedAmount,
    required this.changeAmount,
    required this.transactionTime,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final timeFormatter = DateFormat('dd/MM/yyyy HH:mm');

    // Gaya teks struk (Monospace agar mirip printer thermal)
    const receiptStyle = TextStyle(
      fontFamily: 'Courier',
      fontSize: 14,
      color: Colors.black,
      package: null, // Menggunakan font sistem default yang monospace
    );

    const boldStyle = TextStyle(
      fontFamily: 'Courier',
      fontSize: 14,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, // Kertas putih
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo1.png', // <-- Pastikan nama file sesuai
                    height: 100,               // Atur tinggi logo
                    width: 100,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "PENAK SPACE",
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text("Jl. Bojong, Jatimakmur", style: receiptStyle),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Tgl: ${timeFormatter.format(transactionTime)}",
              style: receiptStyle,
            ),
            const Divider(color: Colors.black, thickness: 1, height: 20),

            // ITEM PESANAN
            ...items.values.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "${item.product.name}\n${item.quantity} x ${currencyFormatter.format(item.product.price)}",
                        style: receiptStyle,
                      ),
                    ),
                    Text(
                      currencyFormatter.format(item.subtotal),
                      style: boldStyle,
                    ),
                  ],
                ),
              );
            }).toList(),

            const Divider(color: Colors.black, thickness: 1, height: 20),

            // TOTAL & PEMBAYARAN
            _buildRow(
              "Total",
              currencyFormatter.format(totalAmount),
              boldStyle,
            ),
            const SizedBox(height: 4),
            _buildRow(
              "Bayar (Cash)",
              currencyFormatter.format(receivedAmount),
              receiptStyle,
            ),
            _buildRow(
              "Kembalian",
              currencyFormatter.format(changeAmount),
              receiptStyle,
            ),

            const SizedBox(height: 20),
            const Center(child: Text("Terima Kasih!", style: receiptStyle)),
            const Center(
              child: Text("Silakan Datang Kembali", style: receiptStyle),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(
                context,
                true,
              ), // Return true jika dicetak/selesai
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text("Tutup / Print Selesai"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
