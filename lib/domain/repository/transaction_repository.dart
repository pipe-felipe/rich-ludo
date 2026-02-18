import '../model/recurring_exclusion.dart';
import '../model/transaction.dart';
import '../../utils/result.dart';

abstract class TransactionRepository {
  Future<Result<List<Transaction>>> getTransactions();

  Future<Result<List<Transaction>>> getTransactionsForMonth(
    int monthStartMillis,
    int monthEndExclusiveMillis,
  );

  Future<Result<int>> makeTransaction(Transaction transaction);

  Future<Result<int>> updateTransaction(Transaction transaction);

  Future<Result<int>> deleteTransaction(int id);

  Future<Result<int>> deleteAllTransactions();

  Future<Result<List<int>>> insertTransactions(List<Transaction> transactions);

  Future<Result<List<RecurringExclusion>>> getExclusions();

  Future<Result<int>> addExclusion(RecurringExclusion exclusion);

  Future<Result<int>> deleteExclusionsForTransaction(int transactionId);

  Future<Result<int>> removeExclusion(
    int transactionId,
    int month,
    int year,
  );
}
