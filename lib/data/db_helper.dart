// ... imports sama seperti sebelumnya ...
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DbHelper {
  // ... singleton code sama ...
  static final DbHelper _instance = DbHelper._internal();
  static Database? _database;
  factory DbHelper() => _instance;
  DbHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(
      await getDatabasesPath(),
      'pos_coffee_dark.db',
    ); // Ganti nama db biar fresh
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabel baru dengan imagePath
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price REAL,
            imagePath TEXT
          )
        ''');
      },
    );
  }

  // ... fungsi insert, get, delete SAMA PERSIS seperti sebelumnya ...
  // (Tidak ada perubahan logika di sini, hanya di struktur tabel di atas)
  Future<int> insertProduct(Product product) async {
    Database db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getProducts() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<int> deleteProduct(int id) async {
    Database db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
