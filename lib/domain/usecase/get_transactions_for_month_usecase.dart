import '../model/transaction.dart';
import '../repository/transaction_repository.dart';
import '../../utils/result.dart';

class GetTransactionsForMonthUseCase {
  final TransactionRepository _repository;

  GetTransactionsForMonthUseCase(this._repository);

  Future<Result<List<Transaction>>> call(int monthStartMillis, int monthEndExclusiveMillis) =>
      _repository.getTransactionsForMonth(monthStartMillis, monthEndExclusiveMillis);
}
