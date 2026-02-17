import '../model/recurring_exclusion.dart';
import '../repository/transaction_repository.dart';
import '../../utils/result.dart';

class GetExclusionsUseCase {
  final TransactionRepository _repository;

  GetExclusionsUseCase(this._repository);

  Future<Result<List<RecurringExclusion>>> call() => _repository.getExclusions();
}
