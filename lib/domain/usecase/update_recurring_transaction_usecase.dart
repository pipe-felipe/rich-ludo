import '../model/month_year.dart';
import '../model/recurring_exclusion.dart';
import '../model/recurring_scope.dart';
import '../model/transaction.dart';
import '../repository/transaction_repository.dart';
import '../../utils/result.dart';

/// Applies an edit to a recurring transaction over the span of months the
/// user chose. [original] is the stored row; [edited] carries the new values
/// and keeps the original `id`, `createdAt` and `humanDate`.
///
/// [RecurringScope.thisAndPreviousMonths] is reachable only while
/// `edited.isRecurring` is true: a one-off row cannot cover past months, so
/// the dialog disables that option when the user turns repetition off.
class UpdateRecurringTransactionUseCase {
  final TransactionRepository _repository;

  UpdateRecurringTransactionUseCase(this._repository);

  Future<Result<int>> call({
    required Transaction original,
    required Transaction edited,
    required RecurringScope scope,
    required int currentMonth,
    required int currentYear,
  }) async {
    final current = MonthYear(currentMonth, currentYear);

    switch (scope) {
      case RecurringScope.allMonths:
        return _updateWholeRule(original, edited);

      case RecurringScope.thisMonth:
        return _updateThisMonth(original, edited, current);

      case RecurringScope.thisAndPreviousMonths:
        return _updateBackwards(original, edited, current);

      case RecurringScope.thisAndFutureMonths:
        return _updateForwards(original, edited, current);
    }
  }

  Future<Result<int>> _updateWholeRule(
    Transaction original,
    Transaction edited,
  ) async {
    if (!edited.isRecurring) {
      await _repository.deleteExclusionsForTransaction(original.id);
    }
    return _repository.updateTransaction(edited);
  }

  Future<Result<int>> _updateThisMonth(
    Transaction original,
    Transaction edited,
    MonthYear current,
  ) async {
    if (_isSingleMonth(original, current)) {
      return _updateWholeRule(original, edited);
    }

    final excluded = await _repository.addExclusion(
      RecurringExclusion(
        transactionId: original.id,
        month: current.month,
        year: current.year,
      ),
    );
    if (excluded.isError) return Result.error(excluded.asError.error);

    return _insertCopy(edited, start: current, end: null, isRecurring: false);
  }

  Future<Result<int>> _updateBackwards(
    Transaction original,
    Transaction edited,
    MonthYear current,
  ) async {
    final next = current.next;
    final end = _endOf(original);

    if (end != null && next.isAfter(end)) {
      return _updateWholeRule(original, edited);
    }

    final moved = await _repository.updateTransaction(
      original.copyWith(targetMonth: next.month, targetYear: next.year),
    );
    if (moved.isError) return moved;

    return _insertCopy(
      edited,
      start: _startOf(original),
      end: current,
      isRecurring: true,
    );
  }

  Future<Result<int>> _updateForwards(
    Transaction original,
    Transaction edited,
    MonthYear current,
  ) async {
    final previous = current.previous;

    if (previous.isBefore(_startOf(original))) {
      return _updateWholeRule(original, edited);
    }

    final truncated = await _repository.updateTransaction(
      original.copyWith(
        endMonth: () => previous.month,
        endYear: () => previous.year,
      ),
    );
    if (truncated.isError) return truncated;

    return _insertCopy(
      edited,
      start: current,
      end: edited.isRecurring ? _endOf(original) : null,
      isRecurring: edited.isRecurring,
    );
  }

  Future<Result<int>> _insertCopy(
    Transaction edited, {
    required MonthYear start,
    required MonthYear? end,
    required bool isRecurring,
  }) {
    return _repository.makeTransaction(
      edited.copyWith(
        id: 0,
        isRecurring: isRecurring,
        targetMonth: start.month,
        targetYear: start.year,
        endMonth: () => end?.month,
        endYear: () => end?.year,
      ),
    );
  }

  bool _isSingleMonth(Transaction tx, MonthYear current) =>
      _startOf(tx) == current && _endOf(tx) == current;

  MonthYear _startOf(Transaction tx) =>
      MonthYear(tx.targetMonth, tx.targetYear);

  MonthYear? _endOf(Transaction tx) => tx.endMonth == null || tx.endYear == null
      ? null
      : MonthYear(tx.endMonth!, tx.endYear!);
}
