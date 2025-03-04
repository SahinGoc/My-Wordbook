import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'dictionary_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Languages table
    await db.execute('''
      CREATE TABLE languages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        language_name TEXT
      )
    ''');

    // Dictionaries table
    await db.execute('''
      CREATE TABLE dictionaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        language_1_id INTEGER,
        language_2_id INTEGER,
        language_1_name TEXT,
        language_2_name TEXT,
        total_number INTEGER,
        record INTEGER
      )
    ''');

    // Words table
    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dictionary_id INTEGER,
        word_in_language_1 TEXT,
        word_in_language_2 TEXT
      )
    ''');

    // Categories table
    await db.execute(''' 
    CREATE TABLE IF NOT EXISTS categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
  ''');

    // Subcategories table (Renkler için alt kategori)
    await db.execute(''' 
    CREATE TABLE IF NOT EXISTS subcategories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      categoryId INTEGER,
      FOREIGN KEY (categoryId) REFERENCES categories (id)
    )
  ''');

    // Items table
    await db.execute(''' 
    CREATE TABLE IF NOT EXISTS items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      price INTEGER NOT NULL,
      code INTEGER, 
      isPurchased INTEGER NOT NULL DEFAULT 0,
      subcategoryId INTEGER,
      categoryId INTEGER,
      FOREIGN KEY (subcategoryId) REFERENCES subcategories (id),
      FOREIGN KEY (categoryId) REFERENCES categories (id)
    )
  ''');


  }
}
