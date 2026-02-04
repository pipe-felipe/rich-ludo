import '../model/transaction.dart';
import '../repository/transaction_repository.dart';
import '../../utils/result.dart';

/// Caso de uso para obter transações de um mês específico
/// Seguindo: https://docs.flutter.dev/app-architecture/guide#optional-domain-layer
class GetTransactionsForMonthUseCase {
  final TransactionRepository _repository;

  GetTransactionsForMonthUseCase(this._repository);

  Future<Result<List<Transaction>>> call(int monthStartMillis, int monthEndExclusiveMillis) =>
      _repository.getTransactionsForMonth(monthStartMillis, monthEndExclusiveMillis);
}
