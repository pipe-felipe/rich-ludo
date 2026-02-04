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
}
