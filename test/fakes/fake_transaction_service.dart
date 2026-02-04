import 'package:rich_ludo/data/services/transaction_service.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/utils/result.dart';

/// Fake do TransactionService para testes
/// Seguindo: https://docs.flutter.dev/app-architecture/case-study/testing
class FakeTransactionService implements TransactionService {
  final List<Transaction> _transactions = [];
  bool shouldReturnError = false;
  
  /// Adiciona uma transação para configurar o estado inicial do teste
  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
  }
  
  /// Limpa todas as transações
  void clear() {
    _transactions.clear();
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
    return Result.ok(count);
  }
}
