import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // [PENTING] Untuk Formatter
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../data/db_helper.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import '../utils/currency_formatter.dart';
import 'checkout_screen.dart';
import '../services/auth_service.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final DbHelper _dbHelper = DbHelper();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    setState(() => _isLoading = true);
    final data = await _dbHelper.getProducts();
    setState(() {
      _products = data;
      _isLoading = false;
    });
  }

  // LOGIC HAPUS MENU
  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Hapus Menu?", style: TextStyle(color: Colors.white)),
        content: Text(
          "Hapus '${product.name}'? Data tidak bisa kembali.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _dbHelper.deleteProduct(product.id!);
              _loadProducts();
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${product.name} dihapus"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("HAPUS", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // DIALOG TAMBAH MENU (DENGAN FORMATTER RUPIAH)
  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController(); // Controller Harga
    final theme = Theme.of(context);
    String? selectedImagePath;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> pickImage() async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (image != null) {
                setStateDialog(() => selectedImagePath = image.path);
              }
            }

            return AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              title: const Text(
                "Tambah Menu Baru",
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Preview Foto
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                          image: selectedImagePath != null
                              ? DecorationImage(
                                  image: FileImage(File(selectedImagePath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: selectedImagePath == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.orange,
                                  ),
                                  Text(
                                    "Tap foto",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Nama
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Nama Menu",
                        prefixIcon: Icon(Icons.coffee),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),

                    // Input Harga (DENGAN TITIK OTOMATIS)
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CurrencyInputFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: "Harga",
                        prefixText: "Rp ",
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    "Batal",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        priceController.text.isNotEmpty) {
                      String cleanPrice = priceController.text.replaceAll(
                        '.',
                        '',
                      );

                      final newProduct = Product(
                        name: nameController.text,
                        price: double.parse(cleanPrice),
                        imagePath:
                            selectedImagePath ??
                            'assets/images/coffee_placeholder.png',
                      );
                      await _dbHelper.insertProduct(newProduct);
                      _loadProducts();
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: const Text("SIMPAN"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo1.png', // <-- Logo Anda
              height: 30, // Ukuran lebih kecil agar muat di AppBar
              fit: BoxFit.contain,
            ),
            SizedBox(width: 10),
            Text("PENAK SPACE"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showAddProductDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? const Center(
              child: Text(
                "Menu Kosong. Tekan + untuk tambah.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.70,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _products.length,
              itemBuilder: (ctx, i) {
                final product = _products[i];
                return GestureDetector(
                  onLongPress: () => _confirmDelete(product),
                  child: ProductCard(product: product),
                );
              },
            ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${cart.items.length} Item",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            currencyFormatter.format(cart.totalPrice),
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CheckoutScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text("CHECKOUT"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
