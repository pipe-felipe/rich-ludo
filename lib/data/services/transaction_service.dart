import 'dart:async';
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

  Future<Result<int>> deleteTransaction(int id);

  Future<Result<int>> deleteAll();
}
