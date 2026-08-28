import '../model/month_year.dart';
import '../model/recurring_exclusion.dart';
import '../model/recurring_scope.dart';
import '../model/transaction.dart';
import '../repository/transaction_repository.dart';
import '../../utils/result.dart';

class DeleteRecurringTransactionUseCase {
  final TransactionRepository _repository;

  DeleteRecurringTransactionUseCase(this._repository);

  Future<Result<int>> call({
    required Transaction transaction,
    required RecurringScope mode,
    required int currentMonth,
    required int currentYear,
  }) async {
    switch (mode) {
      case RecurringScope.allMonths:
        return _deleteAll(transaction.id);

      case RecurringScope.thisMonth:
        return _deleteThisMonth(transaction, currentMonth, currentYear);

      case RecurringScope.thisAndPreviousMonths:
        return _deleteBackwards(transaction, currentMonth, currentYear);

      case RecurringScope.thisAndFutureMonths:
        return _deleteForwards(transaction, currentMonth, currentYear);
    }
  }

  Future<Result<int>> _deleteAll(int id) async {
    await _repository.deleteExclusionsForTransaction(id);
    return _repository.deleteTransaction(id);
  }

  Future<Result<int>> _deleteThisMonth(
    Transaction transaction,
    int month,
    int year,
  ) async {
    // If it is the only month, delete everything
    if (_isSingleMonth(transaction, month, year)) {
      return _deleteAll(transaction.id);
    }

    final exclusion = RecurringExclusion(
      transactionId: transaction.id,
      month: month,
      year: year,
    );
    final result = await _repository.addExclusion(exclusion);
    return result.fold(
      onOk: (_) => const Result.ok(1),
      onError: (e) => Result.error(e),
    );
  }

  Future<Result<int>> _deleteBackwards(
    Transaction transaction,
    int month,
    int year,
  ) async {
    final next = MonthYear(month, year).next;
    final end = _endOf(transaction);

    if (end != null && next.isAfter(end)) {
      return _deleteAll(transaction.id);
    }

    final updated = transaction.copyWith(
      targetMonth: next.month,
      targetYear: next.year,
    );
    return _repository.updateTransaction(updated);
  }

  Future<Result<int>> _deleteForwards(
    Transaction transaction,
    int month,
    int year,
  ) async {
    final previous = MonthYear(month, year).previous;

    if (previous.isBefore(_startOf(transaction))) {
      return _deleteAll(transaction.id);
    }

    final updated = transaction.copyWith(
      endMonth: () => previous.month,
      endYear: () => previous.year,
    );
    return _repository.updateTransaction(updated);
  }

  bool _isSingleMonth(Transaction tx, int month, int year) {
    final current = MonthYear(month, year);
    return _startOf(tx) == current && _endOf(tx) == current;
  }

  MonthYear _startOf(Transaction tx) =>
      MonthYear(tx.targetMonth, tx.targetYear);

  MonthYear? _endOf(Transaction tx) => tx.endMonth == null || tx.endYear == null
      ? null
      : MonthYear(tx.endMonth!, tx.endYear!);
}
