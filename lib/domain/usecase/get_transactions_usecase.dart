import '../model/transaction.dart';
import '../repository/transaction_repository.dart';
import '../../utils/result.dart';

class GetTransactionsUseCase {
  final TransactionRepository _repository;

  GetTransactionsUseCase(this._repository);

  Future<Result<List<Transaction>>> call() => _repository.getTransactions();
}
