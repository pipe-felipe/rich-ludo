import '../model/transaction.dart';
import '../repository/transaction_repository.dart';
import '../../utils/result.dart';

class MakeTransactionUseCase {
  final TransactionRepository _repository;

  MakeTransactionUseCase(this._repository);

  Future<Result<int>> call(Transaction transaction) =>
      _repository.makeTransaction(transaction);
}
