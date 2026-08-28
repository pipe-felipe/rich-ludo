import '../model/transaction.dart';
import '../repository/transaction_repository.dart';
import '../../utils/result.dart';

class UpdateTransactionUseCase {
  final TransactionRepository _repository;

  UpdateTransactionUseCase(this._repository);

  Future<Result<int>> call(Transaction transaction) =>
      _repository.updateTransaction(transaction);
}
