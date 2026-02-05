import 'dart:async';
import 'package:sqflite/sqflite.dart' hide Transaction;
import '../../config/database_config.dart';
import '../../domain/model/transaction.dart';
import '../../domain/model/transaction_mapper.dart';
import '../../utils/result.dart';
import '../local/database/database_helper.dart';
import 'transaction_service.dart';

/// Implementação do TransactionService usando SQLite local
/// Seguindo: https://docs.flutter.dev/app-architecture/case-study/data-layer#define-a-service
class TransactionLocalService implements TransactionService {
  final DatabaseHelper _databaseHelper;

  TransactionLocalService({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  /// Obtém a instância do banco de dados via DatabaseHelper
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
      final id = await db.insert(DatabaseConfig.tableName, TransactionMapper.toMap(transaction));
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
          final id = await txn.insert(DatabaseConfig.tableName, TransactionMapper.toMap(transaction));
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
      final count = await db.delete(DatabaseConfig.tableName);
      return Result.ok(count);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
