import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class User {
  final int id;
  final String username;
  final String password;
  final String uniqueId;
  final String email;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.uniqueId,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_username': username,
      'user_password': password,
      'unique_id': uniqueId,
      'user_email': email,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['user_username'],
      password: map['user_password'],
      uniqueId: map['unique_id'],
      email: map['user_email'],
    );
  }
}

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'user.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE user(id INTEGER PRIMARY KEY, user_username TEXT, user_password TEXT, unique_id TEXT, user_email TEXT)",
        );
      },
      version: 1,
    );
  }

  static Future<void> insert(User user) async {
    final Database db = await database;

    await db.insert(
      'user',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<User>> getUsers() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query('user');

    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  static Future<void> deleteAllUsers() async {
    final Database db = await database;
    await db.delete('user');
  }
}
