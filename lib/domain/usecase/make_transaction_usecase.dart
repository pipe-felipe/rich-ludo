import '../model/recurring_exclusion.dart';
import '../model/transaction.dart';
import '../repository/transaction_repository.dart';
import '../../utils/result.dart';

class MakeTransactionUseCase {
  final TransactionRepository _repository;

  MakeTransactionUseCase(this._repository);

  Future<Result<int>> call(Transaction transaction) async {
    final reactivated = await _tryReactivateExcludedRecurring(transaction);
    if (reactivated != null) return reactivated;

    return _repository.makeTransaction(transaction);
  }

  Future<Result<int>?> _tryReactivateExcludedRecurring(
    Transaction transaction,
  ) async {
    final transactionsResult = await _repository.getTransactions();
    if (transactionsResult.isError) return null;

    final exclusionsResult = await _repository.getExclusions();
    if (exclusionsResult.isError) return null;

    final transactions = transactionsResult.asOk.value;
    final exclusions = exclusionsResult.asOk.value;

    final match = _findMatchingExcludedRecurring(
      transaction,
      transactions,
      exclusions,
    );
    if (match == null) return null;

    return _repository.removeExclusion(
      match.transactionId,
      transaction.targetMonth,
      transaction.targetYear,
    );
  }

  RecurringExclusion? _findMatchingExcludedRecurring(
    Transaction newTx,
    List<Transaction> existing,
    List<RecurringExclusion> exclusions,
  ) {
    for (final tx in existing) {
      if (!tx.isRecurring) continue;
      if (tx.amountCents != newTx.amountCents) continue;
      if (tx.type != newTx.type) continue;
      if (tx.category != newTx.category) continue;

      final exclusion = exclusions
          .where(
            (ex) =>
                ex.transactionId == tx.id &&
                ex.month == newTx.targetMonth &&
                ex.year == newTx.targetYear,
          )
          .firstOrNull;

      if (exclusion != null) return exclusion;
    }
    return null;
  }
}
