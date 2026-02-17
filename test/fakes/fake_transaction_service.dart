import 'package:rich_ludo/data/services/transaction_service.dart';
import 'package:rich_ludo/domain/model/recurring_exclusion.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/utils/result.dart';

class FakeTransactionService implements TransactionService {
  final List<Transaction> _transactions = [];
  final List<RecurringExclusion> _exclusions = [];
  bool shouldReturnError = false;
  
  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
  }
  
  void clear() {
    _transactions.clear();
    _exclusions.clear();
  }

  @override
  Future<Result<List<Transaction>>> getAllTransactions() async {
    if (shouldReturnError) {
      return Result.error(Exception('Erro simulado'));
    }
    return Result.ok(List.unmodifiable(_transactions));
  }

  @override
  Future<Result<List<Transaction>>> getTransactionsForMonth(
    int monthStartMillis,
    int monthEndExclusiveMillis,
  ) async {
    if (shouldReturnError) {
      return Result.error(Exception('Erro simulado'));
    }
    final filtered = _transactions.where((tx) {
      return tx.isRecurring || 
          (tx.createdAt >= monthStartMillis && tx.createdAt < monthEndExclusiveMillis);
    }).toList();
    return Result.ok(filtered);
  }

  @override
  Future<Result<Transaction?>> getTransactionById(int id) async {
    if (shouldReturnError) {
      return Result.error(Exception('Erro simulado'));
    }
    final tx = _transactions.where((t) => t.id == id).firstOrNull;
    return Result.ok(tx);
  }

  @override
  Future<Result<int>> insertTransaction(Transaction transaction) async {
    if (shouldReturnError) {
      return Result.error(Exception('Erro simulado'));
    }
    final newId = _transactions.length + 1;
    _transactions.add(transaction.copyWith(id: newId));
    return Result.ok(newId);
  }

  @override
  Future<Result<List<int>>> insertAll(List<Transaction> transactions) async {
    if (shouldReturnError) {
      return Result.error(Exception('Erro simulado'));
    }
    final ids = <int>[];
    for (final tx in transactions) {
      final newId = _transactions.length + 1;
      _transactions.add(tx.copyWith(id: newId));
      ids.add(newId);
    }
    return Result.ok(ids);
  }

  @override
  Future<Result<int>> deleteTransaction(int id) async {
    if (shouldReturnError) {
      return Result.error(Exception('Erro simulado'));
    }
    final initialLength = _transactions.length;
    _transactions.removeWhere((tx) => tx.id == id);
    return Result.ok(initialLength - _transactions.length);
  }

  @override
  Future<Result<int>> deleteAll() async {
    if (shouldReturnError) {
      return Result.error(Exception('Erro simulado'));
    }
    final count = _transactions.length;
    _transactions.clear();
    _exclusions.clear();
    return Result.ok(count);
  }

  @override
  Future<Result<int>> updateTransaction(Transaction transaction) async {
    if (shouldReturnError) {
      return Result.error(Exception('Erro simulado'));
    }
    final index = _transactions.indexWhere((tx) => tx.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    }
    return Result.ok(index != -1 ? 1 : 0);
  }

  @override
  Future<Result<List<RecurringExclusion>>> getAllExclusions() async {
    if (shouldReturnError) {
      return Result.error(Exception('Erro simulado'));
    }
    return Result.ok(List.unmodifiable(_exclusions));
  }

  @override
  Future<Result<int>> addExclusion(RecurringExclusion exclusion) async {
    if (shouldReturnError) {
      return Result.error(Exception('Erro simulado'));
    }
    final newId = _exclusions.length + 1;
    _exclusions.add(RecurringExclusion(
      id: newId,
      transactionId: exclusion.transactionId,
      month: exclusion.month,
      year: exclusion.year,
    ));
    return Result.ok(newId);
  }

  @override
  Future<Result<int>> deleteExclusionsForTransaction(int transactionId) async {
    if (shouldReturnError) {
      return Result.error(Exception('Erro simulado'));
    }
    final initialLength = _exclusions.length;
    _exclusions.removeWhere((ex) => ex.transactionId == transactionId);
    return Result.ok(initialLength - _exclusions.length);
  }
}
