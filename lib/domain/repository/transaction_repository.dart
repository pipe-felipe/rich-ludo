import '../model/transaction.dart';
import '../../utils/result.dart';

/// Interface do repositório de transações
/// Seguindo a arquitetura Flutter recomendada: https://docs.flutter.dev/app-architecture/case-study/data-layer#define-a-repository
/// 
/// Repositórios são a fonte da verdade para dados da aplicação.
/// Eles transformam dados brutos dos Services em modelos de domínio.
abstract class TransactionRepository {
  /// Retorna todas as transações
  Future<Result<List<Transaction>>> getTransactions();

  /// Retorna transações para um mês específico
  Future<Result<List<Transaction>>> getTransactionsForMonth(
    int monthStartMillis,
    int monthEndExclusiveMillis,
  );

  /// Cria uma nova transação
  Future<Result<int>> makeTransaction(Transaction transaction);

  /// Deleta uma transação por ID
  Future<Result<int>> deleteTransaction(int id);

  /// Deleta todas as transações
  Future<Result<int>> deleteAllTransactions();

  /// Insere múltiplas transações de uma vez
  Future<Result<List<int>>> insertTransactions(List<Transaction> transactions);
}
