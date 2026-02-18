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
  Future<Result<List<Transaction>>> getTransactionsForMonth(
    int monthStartMillis,
    int monthEndExclusiveMillis,
  ) async {
    try {
      final db = await database;
      final maps = await db.query(
        DatabaseConfig.tableName,
        where: 'isRecurring = 1 OR (createdAt >= ? AND createdAt < ?)',
        whereArgs: [monthStartMillis, monthEndExclusiveMillis],
        orderBy: 'createdAt DESC',
      );
      final transactions = maps.map(TransactionMapper.fromMap).toList();
      return Result.ok(transactions);
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
}
