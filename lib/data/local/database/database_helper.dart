import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../../config/database_config.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// Retorna o caminho completo do arquivo do banco de dados
  Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, DatabaseConfig.databaseName);
  }

  Future<Database> _initDB() async {
    final path = await getDatabasePath();

    return await openDatabase(
      path,
      version: DatabaseConfig.databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConfig.tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amountCents INTEGER NOT NULL,
        type TEXT NOT NULL,
        category TEXT,
        description TEXT,
        humanDate TEXT,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL DEFAULT 0,
        targetMonth INTEGER NOT NULL DEFAULT 0,
        targetYear INTEGER NOT NULL DEFAULT 0,
        endMonth INTEGER,
        endYear INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE ${DatabaseConfig.exclusionsTableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transactionId INTEGER NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        FOREIGN KEY (transactionId) REFERENCES ${DatabaseConfig.tableName} (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE ${DatabaseConfig.tableName} ADD COLUMN endMonth INTEGER');
      await db.execute('ALTER TABLE ${DatabaseConfig.tableName} ADD COLUMN endYear INTEGER');
      await db.execute('''
        CREATE TABLE ${DatabaseConfig.exclusionsTableName} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          transactionId INTEGER NOT NULL,
          month INTEGER NOT NULL,
          year INTEGER NOT NULL,
          FOREIGN KEY (transactionId) REFERENCES ${DatabaseConfig.tableName} (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
