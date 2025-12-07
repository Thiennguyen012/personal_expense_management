import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expense_management.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tạo bảng Wallets
    await db.execute('''
      CREATE TABLE wallets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        currency TEXT NOT NULL DEFAULT 'VND',
        createdAt TEXT NOT NULL
      )
    ''');

    // Tạo bảng Categories
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL
      )
    ''');

    // Tạo bảng Transactions
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT
      )
    ''');

    // Thêm các category mặc định
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    List<Map<String, dynamic>> defaultCategories = [
      {'name': 'Lương', 'type': 'income', 'icon': '💼'},
      {'name': 'Thưởng', 'type': 'income', 'icon': '🎁'},
      {'name': 'Đầu tư', 'type': 'income', 'icon': '📈'},
      {'name': 'Ăn uống', 'type': 'expense', 'icon': '🍔'},
      {'name': 'Mua sắm', 'type': 'expense', 'icon': '🛍️'},
      {'name': 'Giao thông', 'type': 'expense', 'icon': '🚗'},
      {'name': 'Điện nước', 'type': 'expense', 'icon': '💡'},
      {'name': 'Giáo dục', 'type': 'expense', 'icon': '📚'},
      {'name': 'Y tế', 'type': 'expense', 'icon': '🏥'},
      {'name': 'Giải trí', 'type': 'expense', 'icon': '🎮'},
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  Future<void> close() async {
    _database?.close();
    _database = null;
  }
}
