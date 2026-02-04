import 'dart:async';
import '../../domain/model/transaction.dart';
import '../../utils/result.dart';

/// Interface abstrata para o serviço de transações (banco de dados local)
/// Serviços são stateless e apenas encapsulam acesso a APIs externas
/// Seguindo: https://docs.flutter.dev/app-architecture/guide#services
abstract class TransactionService {
  /// Retorna todas as transações do banco de dados
  Future<Result<List<Transaction>>> getAllTransactions();

  /// Retorna transações para um período específico
  Future<Result<List<Transaction>>> getTransactionsForMonth(
    int monthStartMillis,
    int monthEndExclusiveMillis,
  );

  /// Obtém uma transação por ID
  Future<Result<Transaction?>> getTransactionById(int id);

  /// Insere uma nova transação e retorna o ID
  Future<Result<int>> insertTransaction(Transaction transaction);

  /// Insere múltiplas transações e retorna os IDs
  Future<Result<List<int>>> insertAll(List<Transaction> transactions);

  /// Deleta uma transação por ID e retorna o número de linhas afetadas
  Future<Result<int>> deleteTransaction(int id);

  /// Deleta todas as transações e retorna o número de linhas afetadas
  Future<Result<int>> deleteAll();
}
