import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rich_ludo/config/database_config.dart';
import 'package:rich_ludo/data/local/database/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Database Migration v1 → v2', () {
    late Database db;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
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
                targetYear INTEGER NOT NULL DEFAULT 0
              )
            ''');
          },
        ),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'v1 database should have original schema without endMonth/endYear columns',
      () async {
        final tableInfo = await db.rawQuery(
          'PRAGMA table_info(${DatabaseConfig.tableName})',
        );
        final columnNames = tableInfo
            .map((col) => col['name'] as String)
            .toSet();

        expect(columnNames.contains('endMonth'), isFalse);
        expect(columnNames.contains('endYear'), isFalse);
      },
    );

    test('v1 database should not have recurring_exclusions table', () async {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='${DatabaseConfig.exclusionsTableName}'",
      );

      expect(tables, isEmpty);
    });

    test('v1->v2 migration should add endMonth and endYear columns', () async {
      await _migrateV1ToV2(db);

      final tableInfo = await db.rawQuery(
        'PRAGMA table_info(${DatabaseConfig.tableName})',
      );
      final columnNames = tableInfo.map((col) => col['name'] as String).toSet();

      expect(columnNames.contains('endMonth'), isTrue);
      expect(columnNames.contains('endYear'), isTrue);
    });

    test('v1->v2 migration should create recurring_exclusions table', () async {
      await _migrateV1ToV2(db);

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='${DatabaseConfig.exclusionsTableName}'",
      );

      expect(tables, isNotEmpty);
      expect(tables.first['name'], equals(DatabaseConfig.exclusionsTableName));
    });

    test(
      'migration should be idempotent (can execute multiple times)',
      () async {
        await _migrateV1ToV2(db);
        await _migrateV1ToV2(db);

        final tableInfo = await db.rawQuery(
          'PRAGMA table_info(${DatabaseConfig.tableName})',
        );
        final columnNames = tableInfo
            .map((col) => col['name'] as String)
            .toSet();

        expect(columnNames.contains('endMonth'), isTrue);
        expect(columnNames.contains('endYear'), isTrue);
      },
    );

    test('existing v1 data should be preserved after migration', () async {
      await db.insert(DatabaseConfig.tableName, {
        'amountCents': 10000,
        'type': 'income',
        'category': 'Salary',
        'description': 'Test',
        'humanDate': '01/01/2026',
        'isRecurring': 0,
        'createdAt': DateTime(2026, 1, 1).millisecondsSinceEpoch,
        'targetMonth': 1,
        'targetYear': 2026,
      });

      await _migrateV1ToV2(db);

      final transactions = await db.query(DatabaseConfig.tableName);

      expect(transactions, hasLength(1));
      expect(transactions.first['amountCents'], equals(10000));
      expect(transactions.first['category'], equals('Salary'));
      expect(transactions.first['endMonth'], isNull);
      expect(transactions.first['endYear'], isNull);
    });

    test(
      'v1 transactions with isRecurring should work after migration (endMonth/endYear null)',
      () async {
        await db.insert(DatabaseConfig.tableName, {
          'amountCents': 5000,
          'type': 'expense',
          'category': 'Assinatura',
          'description': 'Netflix',
          'humanDate': '01/01/2026',
          'isRecurring': 1,
          'createdAt': DateTime(2026, 1, 1).millisecondsSinceEpoch,
          'targetMonth': 1,
          'targetYear': 2026,
        });

        await _migrateV1ToV2(db);

        final transactions = await db.query(DatabaseConfig.tableName);

        expect(transactions, hasLength(1));
        expect(transactions.first['isRecurring'], equals(1));
        expect(transactions.first['endMonth'], isNull);
        expect(transactions.first['endYear'], isNull);
      },
    );
  });

  group('Database Migration v2 → v3', () {
    late Database db;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (db, version) async {
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
          },
        ),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('v2 database should not have the categories table', () async {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='${DatabaseConfig.categoriesTableName}'",
      );

      expect(tables, isEmpty);
    });

    test('v2->v3 migration should create the categories table', () async {
      await DatabaseHelper.forTesting(db).validateAndMigrateIfNeeded();

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='${DatabaseConfig.categoriesTableName}'",
      );

      expect(tables, hasLength(1));
    });

    test('v2->v3 migration should set the database version to 3', () async {
      await DatabaseHelper.forTesting(db).validateAndMigrateIfNeeded();

      final versionResult = await db.rawQuery('PRAGMA user_version');

      expect(versionResult.first['user_version'], equals(3));
    });

    test('existing v2 data should be preserved after migration', () async {
      final transactionId = await db.insert(DatabaseConfig.tableName, {
        'amountCents': 12345,
        'type': 'expense',
        'category': 'food',
        'description': 'Groceries',
        'humanDate': '2026-08-02',
        'isRecurring': 1,
        'createdAt': DateTime(2026, 8, 1).millisecondsSinceEpoch,
        'targetMonth': 8,
        'targetYear': 2026,
        'endMonth': 12,
        'endYear': 2026,
      });
      await db.insert(DatabaseConfig.exclusionsTableName, {
        'transactionId': transactionId,
        'month': 9,
        'year': 2026,
      });

      await DatabaseHelper.forTesting(db).validateAndMigrateIfNeeded();

      final transactions = await db.query(DatabaseConfig.tableName);
      final exclusions = await db.query(DatabaseConfig.exclusionsTableName);

      expect(transactions, hasLength(1));
      expect(transactions.first['amountCents'], equals(12345));
      expect(transactions.first['category'], equals('food'));
      expect(transactions.first['description'], equals('Groceries'));
      expect(transactions.first['isRecurring'], equals(1));
      expect(transactions.first['endMonth'], equals(12));
      expect(transactions.first['endYear'], equals(2026));
      expect(exclusions, hasLength(1));
      expect(exclusions.first['transactionId'], equals(transactionId));
      expect(exclusions.first['month'], equals(9));
    });

    test('migration should be idempotent (can execute multiple times)', () async {
      await DatabaseHelper.forTesting(db).validateAndMigrateIfNeeded();
      await DatabaseHelper.forTesting(db).validateAndMigrateIfNeeded();

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='${DatabaseConfig.categoriesTableName}'",
      );

      expect(tables, hasLength(1));
    });

    test(
      'categories table should reject a duplicate slug for the same type',
      () async {
        await DatabaseHelper.forTesting(db).validateAndMigrateIfNeeded();

        const row = {
          'slug': 'custom_mercado',
          'name': 'Mercado',
          'type': 'expense',
          'iconCodePoint': 0xe59c,
          'colorValue': 0xFFC62828,
          'createdAt': 0,
        };
        await db.insert(DatabaseConfig.categoriesTableName, row);

        await expectLater(
          db.insert(DatabaseConfig.categoriesTableName, row),
          throwsA(isA<DatabaseException>()),
        );
      },
    );

    test(
      'categories table should accept the same slug for the other type',
      () async {
        await DatabaseHelper.forTesting(db).validateAndMigrateIfNeeded();

        await db.insert(DatabaseConfig.categoriesTableName, {
          'slug': 'custom_bonus',
          'name': 'Bonus',
          'type': 'expense',
          'iconCodePoint': 0xe59c,
          'colorValue': 0xFFC62828,
          'createdAt': 0,
        });
        await db.insert(DatabaseConfig.categoriesTableName, {
          'slug': 'custom_bonus',
          'name': 'Bonus',
          'type': 'income',
          'iconCodePoint': 0xe59c,
          'colorValue': 0xFFC62828,
          'createdAt': 0,
        });

        final rows = await db.query(DatabaseConfig.categoriesTableName);

        expect(rows, hasLength(2));
      },
    );
  });

  group('Database Migration v1 → v3', () {
    late Database db;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
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
                targetYear INTEGER NOT NULL DEFAULT 0
              )
            ''');
          },
        ),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('a restored v1 backup should reach v3 with its rows intact', () async {
      await db.insert(DatabaseConfig.tableName, {
        'amountCents': 999,
        'type': 'income',
        'category': 'salary',
        'description': 'Old backup row',
        'humanDate': '01/01/2026',
        'isRecurring': 0,
        'createdAt': DateTime(2026, 1, 1).millisecondsSinceEpoch,
        'targetMonth': 1,
        'targetYear': 2026,
      });

      await DatabaseHelper.forTesting(db).validateAndMigrateIfNeeded();

      final tableInfo = await db.rawQuery(
        'PRAGMA table_info(${DatabaseConfig.tableName})',
      );
      final columnNames = tableInfo.map((col) => col['name'] as String).toSet();
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('${DatabaseConfig.exclusionsTableName}', '${DatabaseConfig.categoriesTableName}')",
      );
      final versionResult = await db.rawQuery('PRAGMA user_version');
      final transactions = await db.query(DatabaseConfig.tableName);

      expect(columnNames.contains('endMonth'), isTrue);
      expect(columnNames.contains('endYear'), isTrue);
      expect(tables, hasLength(2));
      expect(versionResult.first['user_version'], equals(3));
      expect(transactions, hasLength(1));
      expect(transactions.first['amountCents'], equals(999));
      expect(transactions.first['description'], equals('Old backup row'));
    });
  });
}

Future<void> _migrateV1ToV2(Database db) async {
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
