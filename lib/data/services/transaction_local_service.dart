import 'dart:async';
import 'package:sqflite/sqflite.dart' hide Transaction;
import '../../config/database_config.dart';
import '../../domain/model/recurring_exclusion.dart';
import '../../domain/model/recurring_exclusion_mapper.dart';
import '../../domain/model/transaction.dart';
import '../../domain/model/transaction_mapper.dart';
import '../../utils/result.dart';
import '../local/database/database_helper.dart';
import 'transaction_service.dart';

class TransactionLocalService implements TransactionService {
  final DatabaseHelper _databaseHelper;

  TransactionLocalService({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  Future<Database> get database => _databaseHelper.database;

  @override
  Future<Result<List<Transaction>>> getAllTransactions() async {
    try {
      final db = await database;
      final maps = await db.query(
        DatabaseConfig.tableName,
        orderBy: 'createdAt DESC',
      );
      final transactions = maps.map(TransactionMapper.fromMap).toList();
      return Result.ok(transactions);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<List<Transaction>>> getTransactionsByMonthYear(
    int month,
    int year,
  ) async {
    try {
      final db = await database;
      final maps = await db.query(
        DatabaseConfig.tableName,
        where: 'isRecurring = 1 OR (targetMonth = ? AND targetYear = ?)',
        whereArgs: [month, year],
        orderBy: 'createdAt DESC',
      );
      final transactions = maps.map(TransactionMapper.fromMap).toList();
      return Result.ok(transactions);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<int>> getNonRecurringBalance(int upToMonth, int upToYear) async {
    try {
      final db = await database;
      // We sum the signed amount (income is positive, expense is negative)
      // for all past non-recurring transactions until the provided date.
      final result = await db.rawQuery('''
        SELECT SUM(
          CASE 
            WHEN type = 'income' THEN amountCents 
            ELSE -amountCents 
          END
        ) as balance
        FROM ${DatabaseConfig.tableName}
        WHERE isRecurring = 0 
          AND (targetYear < ? OR (targetYear = ? AND targetMonth <= ?))
      ''', [upToYear, upToYear, upToMonth]);

      int balance = 0;
      if (result.isNotEmpty && result.first['balance'] != null) {
        balance = result.first['balance'] as int;
      }
      return Result.ok(balance);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<Transaction?>> getTransactionById(int id) async {
    try {
      final db = await database;
      final maps = await db.query(
        DatabaseConfig.tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        return const Result.ok(null);
      }
      return Result.ok(TransactionMapper.fromMap(maps.first));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<int>> insertTransaction(Transaction transaction) async {
    try {
      final db = await database;
      final id = await db.insert(
        DatabaseConfig.tableName,
        TransactionMapper.toMap(transaction),
      );
      return Result.ok(id);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<List<int>>> insertAll(List<Transaction> transactions) async {
    try {
      final db = await database;
      final ids = <int>[];

      await db.transaction((txn) async {
        for (final transaction in transactions) {
          final id = await txn.insert(
            DatabaseConfig.tableName,
            TransactionMapper.toMap(transaction),
          );
          ids.add(id);
        }
      });

      return Result.ok(ids);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<int>> deleteTransaction(int id) async {
    try {
      final db = await database;
      final count = await db.delete(
        DatabaseConfig.tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      return Result.ok(count);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<int>> deleteAll() async {
    try {
      final db = await database;
      await db.delete(DatabaseConfig.exclusionsTableName);
      final count = await db.delete(DatabaseConfig.tableName);
      return Result.ok(count);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<int>> updateTransaction(Transaction transaction) async {
    try {
      final db = await database;
      final count = await db.update(
        DatabaseConfig.tableName,
        TransactionMapper.toMap(transaction),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
      return Result.ok(count);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<List<RecurringExclusion>>> getAllExclusions() async {
    try {
      final db = await database;
      final maps = await db.query(DatabaseConfig.exclusionsTableName);
      final exclusions = maps.map(RecurringExclusionMapper.fromMap).toList();
      return Result.ok(exclusions);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<int>> addExclusion(RecurringExclusion exclusion) async {
    try {
      final db = await database;
      final id = await db.insert(
        DatabaseConfig.exclusionsTableName,
        RecurringExclusionMapper.toMap(exclusion),
      );
      return Result.ok(id);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<int>> deleteExclusionsForTransaction(int transactionId) async {
    try {
      final db = await database;
      final count = await db.delete(
        DatabaseConfig.exclusionsTableName,
        where: 'transactionId = ?',
        whereArgs: [transactionId],
      );
      return Result.ok(count);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<int>> removeExclusion(
    int transactionId,
    int month,
    int year,
  ) async {
    try {
      final db = await database;
      final count = await db.delete(
        DatabaseConfig.exclusionsTableName,
        where: 'transactionId = ? AND month = ? AND year = ?',
        whereArgs: [transactionId, month, year],
      );
      return Result.ok(count);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
