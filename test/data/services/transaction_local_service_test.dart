import 'package:flutter_test/flutter_test.dart';
import 'package:rich_ludo/config/database_config.dart';
import 'package:rich_ludo/data/local/database/database_helper.dart';
import 'package:rich_ludo/data/services/transaction_local_service.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/domain/model/transaction_mapper.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/utils/result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database database;
  late TransactionLocalService service;

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DatabaseConfig.databaseVersion,
        onCreate: (db, version) async {
          await _createSchema(db);
        },
      ),
    );
    service = TransactionLocalService(
      databaseHelper: DatabaseHelper.forTesting(database),
    );
  });

  tearDown(() => database.close());

  test(
    'should return recurring rows and one-time rows for the requested month',
    () async {
      const requestedMonth = 6;
      const requestedYear = 2026;
      final transactions = [
        _transaction(
          id: 1,
          description: 'requested one-time',
          amountCents: 1000,
          targetMonth: requestedMonth,
          targetYear: requestedYear,
        ),
        _transaction(
          id: 2,
          description: 'other month one-time',
          amountCents: 2000,
          targetMonth: 5,
          targetYear: requestedYear,
        ),
        _transaction(
          id: 3,
          description: 'recurring before month',
          amountCents: 3000,
          targetMonth: 5,
          targetYear: requestedYear,
          isRecurring: true,
        ),
        _transaction(
          id: 4,
          description: 'recurring after month',
          amountCents: 4000,
          targetMonth: 7,
          targetYear: requestedYear,
          isRecurring: true,
        ),
      ];

      await database.transaction((txn) async {
        for (final transaction in transactions) {
          await txn.insert(
            DatabaseConfig.tableName,
            TransactionMapper.toMap(transaction),
          );
        }
      });

      final result = await service.getTransactionsByMonthYear(
        requestedMonth,
        requestedYear,
      );

      expect(result, isA<Ok<List<Transaction>>>());
      final returnedDescriptions = result.asOk.value
          .map((transaction) => transaction.description)
          .toSet();

      expect(
        returnedDescriptions,
        containsAll(<String?>[
          'requested one-time',
          'recurring before month',
          'recurring after month',
        ]),
      );
      expect(returnedDescriptions, isNot(contains('other month one-time')));
      expect(result.asOk.value, hasLength(3));
    },
  );
}

Transaction _transaction({
  required int id,
  required String description,
  required int amountCents,
  required int targetMonth,
  required int targetYear,
  bool isRecurring = false,
}) {
  return Transaction(
    id: id,
    amountCents: amountCents,
    type: TransactionType.income,
    description: description,
    isRecurring: isRecurring,
    targetMonth: targetMonth,
    targetYear: targetYear,
  );
}

Future<void> _createSchema(Database database) async {
  await database.execute('''
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
  await database.execute('''
    CREATE TABLE ${DatabaseConfig.exclusionsTableName} (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      transactionId INTEGER NOT NULL,
      month INTEGER NOT NULL,
      year INTEGER NOT NULL,
      FOREIGN KEY (transactionId) REFERENCES ${DatabaseConfig.tableName} (id)
    )
  ''');
}
