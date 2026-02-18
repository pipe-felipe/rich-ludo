import '../../domain/model/recurring_exclusion.dart';
import '../../domain/model/transaction.dart';
import '../../domain/repository/transaction_repository.dart';
import '../../utils/result.dart';
import '../services/transaction_service.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionService _service;

  TransactionRepositoryImpl({required TransactionService service})
    : _service = service;

  @override
  Future<Result<List<Transaction>>> getTransactions() {
    return _service.getAllTransactions();
  }

  @override
  Future<Result<List<Transaction>>> getTransactionsForMonth(
    int monthStartMillis,
    int monthEndExclusiveMillis,
  ) {
    return _service.getTransactionsForMonth(
      monthStartMillis,
      monthEndExclusiveMillis,
    );
  }

  @override
  Future<Result<int>> makeTransaction(Transaction transaction) {
    return _service.insertTransaction(transaction);
  }

  @override
  Future<Result<int>> updateTransaction(Transaction transaction) {
    return _service.updateTransaction(transaction);
  }

  @override
  Future<Result<int>> deleteTransaction(int id) {
    return _service.deleteTransaction(id);
  }

  @override
  Future<Result<int>> deleteAllTransactions() {
    return _service.deleteAll();
  }

  @override
  Future<Result<List<int>>> insertTransactions(List<Transaction> transactions) {
    return _service.insertAll(transactions);
  }

  @override
  Future<Result<List<RecurringExclusion>>> getExclusions() {
    return _service.getAllExclusions();
  }

  @override
  Future<Result<int>> addExclusion(RecurringExclusion exclusion) {
    return _service.addExclusion(exclusion);
  }

  @override
  Future<Result<int>> deleteExclusionsForTransaction(int transactionId) {
    return _service.deleteExclusionsForTransaction(transactionId);
  }

  @override
  Future<Result<int>> removeExclusion(
    int transactionId,
    int month,
    int year,
  ) {
    return _service.removeExclusion(transactionId, month, year);
  }
}
