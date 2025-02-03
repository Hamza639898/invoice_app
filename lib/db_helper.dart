import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  DBHelper._internal();

  factory DBHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'inventory.db');

    return await openDatabase(
      path,
      version: 3, //  logs
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            password TEXT NOT NULL,
            userType TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE inventory (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            price REAL NOT NULL,
            date TEXT NOT NULL,
            deliverTo TEXT NOT NULL,
            "in" INTEGER NOT NULL,
            "out" INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            action TEXT NOT NULL,
            timestamp TEXT NOT NULL
          )
        ''');

        await db.insert('users', {
          'username': 'admin',
          'password': 'admin123',
          'userType': 'Admin',
        });
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE inventory ADD COLUMN date TEXT');
          await db.execute('ALTER TABLE inventory ADD COLUMN deliverTo TEXT');
          await db.execute('ALTER TABLE inventory ADD COLUMN "in" INTEGER DEFAULT 0');
          await db.execute('ALTER TABLE inventory ADD COLUMN "out" INTEGER DEFAULT 0');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE logs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              action TEXT NOT NULL,
              timestamp TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  Future<Map<String, dynamic>?> getUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertUser(String username, String password, String userType) async {
    final db = await database;
    final result = await db.insert('users', {
      'username': username,
      'password': password,
      'userType': userType,
    });
    await addLog('Added new user: $username');
    return result;
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<int> addItem(
      String name,
      int quantity,
      double price,
      String date,
      String deliverTo,
      int inValue,
      int outValue) async {
    final db = await database;
    final result = await db.insert('inventory', {
      'name': name,
      'quantity': quantity,
      'price': price,
      'date': date,
      'deliverTo': deliverTo,
      '"in"': inValue,
      '"out"': outValue,
    });
    await addLog('Added new item: $name');
    return result;
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await database;
    return await db.query('inventory');
  }

  Future<int> updateItem(
      int id,
      String name,
      int quantity,
      double price,
      String date,
      String deliverTo,
      int inValue,
      int outValue) async {
    final db = await database;
    final result = await db.update(
      'inventory',
      {
        'name': name,
        'quantity': quantity,
        'price': price,
        'date': date,
        'deliverTo': deliverTo,
        '"in"': inValue,
        '"out"': outValue,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    await addLog('Updated item: $name');
    return result;
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    final result = await db.delete(
      'inventory',
      where: 'id = ?',
      whereArgs: [id],
    );
    await addLog('Deleted item with ID: $id');
    return result;
  }

  Future<int> updateUser(int id, String username, String password, String userType) async {
    final db = await database;
    final result = await db.update(
      'users',
      {
        'username': username,
        'password': password,
        'userType': userType,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    await addLog('Updated user: $username');
    return result;
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    final result = await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    await addLog('Deleted user with ID: $id');
    return result;
  }

  //add new active log
  Future<int> addLog(String action) async {
    final db = await database;
    return await db.insert('logs', {
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // active logs  uwacasho
  Future<List<Map<String, dynamic>>> getLogs() async {
    final db = await database;
    return await db.query('logs', orderBy: 'timestamp DESC');
  }
}
