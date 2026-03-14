import '../repository/transaction_repository.dart';
import '../../utils/result.dart';

class GetNonRecurringBalanceUseCase {
  final TransactionRepository _repository;

  GetNonRecurringBalanceUseCase(this._repository);

  Future<Result<int>> call({
    required int upToMonth,
    required int upToYear,
  }) {
    return _repository.getNonRecurringBalance(upToMonth, upToYear);
  }
}
