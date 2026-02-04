import '../model/transaction.dart';
import '../repository/transaction_repository.dart';
import '../../utils/result.dart';

/// Caso de uso para criar uma nova transação
/// Seguindo: https://docs.flutter.dev/app-architecture/guide#optional-domain-layer
class MakeTransactionUseCase {
  final TransactionRepository _repository;

  MakeTransactionUseCase(this._repository);

  Future<Result<int>> call(Transaction transaction) =>
      _repository.makeTransaction(transaction);
}
