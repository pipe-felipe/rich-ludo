import 'dart:async';
import '../database/database_helper.dart';
import '../../../domain/model/transaction.dart';
import '../../../domain/model/transaction_type.dart';

class TransactionDao {
  final DatabaseHelper _databaseHelper;
  final _transactionsController = StreamController<List<Transaction>>.broadcast();

  TransactionDao(this._databaseHelper) {
    _refreshTransactions();
  }

  Stream<List<Transaction>> getAllTransactions() {
    _refreshTransactions();
    return _transactionsController.stream;
  }

  Future<void> _refreshTransactions() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'transactions',
      orderBy: 'createdAt DESC',
    );

    final transactions = maps.map((map) => _mapToTransaction(map)).toList();
    _transactionsController.add(transactions);
  }

  Stream<List<Transaction>> getTransactionsForMonth(
    int monthStartMillis,
    int monthEndExclusiveMillis,
  ) {
    final controller = StreamController<List<Transaction>>();

    _getTransactionsForMonthOnce(monthStartMillis, monthEndExclusiveMillis)
        .then((transactions) {
      controller.add(transactions);
      controller.close();
    });

    return controller.stream;
  }

  Future<List<Transaction>> _getTransactionsForMonthOnce(
    int monthStartMillis,
    int monthEndExclusiveMillis,
  ) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'isRecurring = 1 OR (createdAt >= ? AND createdAt < ?)',
      whereArgs: [monthStartMillis, monthEndExclusiveMillis],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => _mapToTransaction(map)).toList();
  }

  Future<Transaction?> getTransactionById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return _mapToTransaction(maps.first);
  }

  Future<int> addTransaction(Transaction transaction) async {
    final db = await _databaseHelper.database;
    final id = await db.insert('transactions', _transactionToMap(transaction));
    _refreshTransactions();
    return id;
  }

  Future<List<int>> insertAll(List<Transaction> transactions) async {
    final db = await _databaseHelper.database;
    final ids = <int>[];

    await db.transaction((txn) async {
      for (final transaction in transactions) {
        final id = await txn.insert('transactions', _transactionToMap(transaction));
        ids.add(id);
      }
    });

    _refreshTransactions();
    return ids;
  }

  Future<int> deleteTransactionById(int id) async {
    final db = await _databaseHelper.database;
    final count = await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    _refreshTransactions();
    return count;
  }

  Future<int> deleteAll() async {
    final db = await _databaseHelper.database;
    final count = await db.delete('transactions');
    _refreshTransactions();
    return count;
  }

  Transaction _mapToTransaction(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int,
      amountCents: map['amountCents'] as int,
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      category: map['category'] as String?,
      description: map['description'] as String?,
      humanDate: (map['humanDate'] as String?) ?? '',
      isRecurring: (map['isRecurring'] as int) == 1,
      createdAt: map['createdAt'] as int,
      targetMonth: map['targetMonth'] as int,
      targetYear: map['targetYear'] as int,
    );
  }

  Map<String, dynamic> _transactionToMap(Transaction transaction) {
    return {
      'amountCents': transaction.amountCents,
      'type': transaction.type == TransactionType.income ? 'income' : 'expense',
      'category': transaction.category,
      'description': transaction.description,
      'humanDate': transaction.humanDate,
      'isRecurring': transaction.isRecurring ? 1 : 0,
      'createdAt': transaction.createdAt,
      'targetMonth': transaction.targetMonth,
      'targetYear': transaction.targetYear,
    };
  }

  void dispose() {
    _transactionsController.close();
  }
}
