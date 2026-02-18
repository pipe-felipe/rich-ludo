import 'dart:async';
import '../../domain/model/recurring_exclusion.dart';
import '../../domain/model/transaction.dart';
import '../../utils/result.dart';

abstract class TransactionService {
  Future<Result<List<Transaction>>> getAllTransactions();

  Future<Result<List<Transaction>>> getTransactionsForMonth(
    int monthStartMillis,
    int monthEndExclusiveMillis,
  );

  Future<Result<Transaction?>> getTransactionById(int id);

  Future<Result<int>> insertTransaction(Transaction transaction);

  Future<Result<List<int>>> insertAll(List<Transaction> transactions);

  Future<Result<int>> updateTransaction(Transaction transaction);

  Future<Result<int>> deleteTransaction(int id);

  Future<Result<int>> deleteAll();

  Future<Result<List<RecurringExclusion>>> getAllExclusions();

  Future<Result<int>> addExclusion(RecurringExclusion exclusion);

  Future<Result<int>> deleteExclusionsForTransaction(int transactionId);

  Future<Result<int>> removeExclusion(
    int transactionId,
    int month,
    int year,
  );
}
