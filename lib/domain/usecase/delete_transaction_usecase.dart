import '../repository/transaction_repository.dart';
import '../../utils/result.dart';


class DeleteTransactionUseCase {
  final TransactionRepository _repository;

  DeleteTransactionUseCase(this._repository);

  Future<Result<int>> call(int id) => _repository.deleteTransaction(id);
}
