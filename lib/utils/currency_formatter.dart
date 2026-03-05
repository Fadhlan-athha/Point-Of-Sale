import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // 1. Jika input kosong, biarkan kosong
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 2. Bersihkan input dari karakter selain angka (hapus titik lama)
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Mencegah error jika user menghapus habis semua angka
    if (cleanText.isEmpty) {
       return newValue.copyWith(text: '');
    }

    // 3. Ubah string angka menjadi format Rupiah (10000 -> 10.000)
    double value = double.parse(cleanText);
    final formatter = NumberFormat.decimalPattern('id_ID'); 
    String newText = formatter.format(value);

    // 4. Kembalikan teks baru & letakkan kursor di paling kanan
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}