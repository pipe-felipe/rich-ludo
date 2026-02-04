import '../model/transaction.dart';
import '../repository/transaction_repository.dart';
import '../../utils/result.dart';

/// Caso de uso para obter todas as transações
/// Seguindo: https://docs.flutter.dev/app-architecture/guide#optional-domain-layer
class GetTransactionsUseCase {
  final TransactionRepository _repository;

  GetTransactionsUseCase(this._repository);

  Future<Result<List<Transaction>>> call() => _repository.getTransactions();
}
