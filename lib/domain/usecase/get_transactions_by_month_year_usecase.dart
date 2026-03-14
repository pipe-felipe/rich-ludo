import '../model/transaction.dart';
import '../repository/transaction_repository.dart';
import '../../utils/result.dart';

class GetTransactionsByMonthYearUseCase {
  final TransactionRepository _repository;

  GetTransactionsByMonthYearUseCase(this._repository);

  Future<Result<List<Transaction>>> call({
    required int month,
    required int year,
  }) {
    return _repository.getTransactionsByMonthYear(month, year);
  }
}
