class Product {
  final int? id;
  final String name;
  final double price;
  final String imagePath; // Path gambar (aset lokal atau URL nanti)

  Product({
    this.id,
    required this.name,
    required this.price,
    this.imagePath = 'assets/images/coffee_placeholder.png', // Default image
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      imagePath: map['imagePath'] ?? 'assets/images/coffee_placeholder.png',
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'price': price, 'imagePath': imagePath};
  }
}
