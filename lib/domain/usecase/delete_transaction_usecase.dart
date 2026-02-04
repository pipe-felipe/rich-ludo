import '../repository/transaction_repository.dart';
import '../../utils/result.dart';

/// Caso de uso para deletar uma transação
/// Seguindo: https://docs.flutter.dev/app-architecture/guide#optional-domain-layer
class DeleteTransactionUseCase {
  final TransactionRepository _repository;

  DeleteTransactionUseCase(this._repository);

  Future<Result<int>> call(int id) => _repository.deleteTransaction(id);
}
