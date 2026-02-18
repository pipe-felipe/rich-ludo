import '../model/recurring_exclusion.dart';
import '../model/transaction.dart';
import '../repository/transaction_repository.dart';
import '../../utils/result.dart';

enum RecurringDeleteMode {
  thisMonth,
  allMonths,
  thisAndPreviousMonths,
  thisAndFutureMonths,
}

class DeleteRecurringTransactionUseCase {
  final TransactionRepository _repository;

  DeleteRecurringTransactionUseCase(this._repository);

  Future<Result<int>> call({
    required Transaction transaction,
    required RecurringDeleteMode mode,
    required int currentMonth,
    required int currentYear,
  }) async {
    switch (mode) {
      case RecurringDeleteMode.allMonths:
        return _deleteAll(transaction.id);

      case RecurringDeleteMode.thisMonth:
        return _deleteThisMonth(transaction, currentMonth, currentYear);

      case RecurringDeleteMode.thisAndPreviousMonths:
        return _deleteBackwards(transaction, currentMonth, currentYear);

      case RecurringDeleteMode.thisAndFutureMonths:
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
    // Se é o único mês, deletar tudo
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
    final (nextMonth, nextYear) = _nextMonth(month, year);

    if (transaction.endMonth != null && transaction.endYear != null) {
      if (_isAfter(
        nextMonth,
        nextYear,
        transaction.endMonth!,
        transaction.endYear!,
      )) {
        return _deleteAll(transaction.id);
      }
    }

    final updated = transaction.copyWith(
      targetMonth: nextMonth,
      targetYear: nextYear,
    );
    return _repository.updateTransaction(updated);
  }

  Future<Result<int>> _deleteForwards(
    Transaction transaction,
    int month,
    int year,
  ) async {
    final (prevMonth, prevYear) = _previousMonth(month, year);

    if (_isBefore(
      prevMonth,
      prevYear,
      transaction.targetMonth,
      transaction.targetYear,
    )) {
      return _deleteAll(transaction.id);
    }

    final updated = transaction.copyWith(
      endMonth: () => prevMonth,
      endYear: () => prevYear,
    );
    return _repository.updateTransaction(updated);
  }

  bool _isSingleMonth(Transaction tx, int month, int year) {
    final isStart = tx.targetMonth == month && tx.targetYear == year;
    final isEnd = tx.endMonth == month && tx.endYear == year;
    return isStart && isEnd;
  }

  bool _isAfter(int m1, int y1, int m2, int y2) {
    return y1 > y2 || (y1 == y2 && m1 > m2);
  }

  bool _isBefore(int m1, int y1, int m2, int y2) {
    return y1 < y2 || (y1 == y2 && m1 < m2);
  }

  (int month, int year) _nextMonth(int month, int year) {
    if (month == 12) return (1, year + 1);
    return (month + 1, year);
  }

  (int month, int year) _previousMonth(int month, int year) {
    if (month == 1) return (12, year - 1);
    return (month - 1, year);
  }
}
