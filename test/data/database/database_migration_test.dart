import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rich_ludo/config/database_config.dart';

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
      'banco v1 deve ter schema original sem colunas endMonth/endYear',
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

    test('banco v1 não deve ter tabela recurring_exclusions', () async {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='${DatabaseConfig.exclusionsTableName}'",
      );

      expect(tables, isEmpty);
    });

    test('migração v1→v2 deve adicionar colunas endMonth e endYear', () async {
      await _migrateV1ToV2(db);

      final tableInfo = await db.rawQuery(
        'PRAGMA table_info(${DatabaseConfig.tableName})',
      );
      final columnNames = tableInfo.map((col) => col['name'] as String).toSet();

      expect(columnNames.contains('endMonth'), isTrue);
      expect(columnNames.contains('endYear'), isTrue);
    });

    test('migração v1→v2 deve criar tabela recurring_exclusions', () async {
      await _migrateV1ToV2(db);

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='${DatabaseConfig.exclusionsTableName}'",
      );

      expect(tables, isNotEmpty);
      expect(tables.first['name'], equals(DatabaseConfig.exclusionsTableName));
    });

    test(
      'migração deve ser idempotente (pode executar múltiplas vezes)',
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

    test('dados existentes v1 devem ser preservados após migração', () async {
      await db.insert(DatabaseConfig.tableName, {
        'amountCents': 10000,
        'type': 'income',
        'category': 'Salário',
        'description': 'Teste',
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
      expect(transactions.first['category'], equals('Salário'));
      expect(transactions.first['endMonth'], isNull);
      expect(transactions.first['endYear'], isNull);
    });

    test(
      'transações v1 com isRecurring devem funcionar após migração (endMonth/endYear null)',
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
