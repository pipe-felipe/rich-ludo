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
      await _migrateToV2(db);
    }
  }

  Future<void> _migrateToV2(Database db) async {
    final tableInfo = await db.rawQuery(
      'PRAGMA table_info(${DatabaseConfig.tableName})',
    );
    final columnNames = tableInfo.map((col) => col['name'] as String).toSet();

    if (!columnNames.contains('endMonth')) {
      await db.execute(
        'ALTER TABLE ${DatabaseConfig.tableName} ADD COLUMN endMonth INTEGER',
      );
    }

    if (!columnNames.contains('endYear')) {
      await db.execute(
        'ALTER TABLE ${DatabaseConfig.tableName} ADD COLUMN endYear INTEGER',
      );
    }

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='${DatabaseConfig.exclusionsTableName}'",
    );

    if (tables.isEmpty) {
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

  Future<void> validateAndMigrateIfNeeded() async {
    final db = await database;

    final versionResult = await db.rawQuery('PRAGMA user_version');
    final currentVersion = versionResult.first['user_version'] as int;

    if (currentVersion < DatabaseConfig.databaseVersion) {
      if (currentVersion < 2) {
        await _migrateToV2(db);
      }

      await db.execute(
        'PRAGMA user_version = ${DatabaseConfig.databaseVersion}',
      );
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
