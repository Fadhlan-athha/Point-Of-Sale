import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
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
    String path = join(await getDatabasesPath(), 'pos_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabel untuk menyimpan Menu/Produk
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price REAL,
            category TEXT
          )
        ''');
      },
    );
  }

  // Fungsi menambah menu baru
  Future<int> insertProduct(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('products', row);
  }

  // Fungsi mengambil semua menu
  Future<List<Map<String, dynamic>>> queryAllProducts() async {
    Database db = await database;
    return await db.query('products');
  }

  // Fungsi menghapus menu
  Future<int> deleteProduct(int id) async {
    Database db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
