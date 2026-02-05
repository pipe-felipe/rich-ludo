import 'transaction.dart';
import 'transaction_type.dart';

/// Classe utilitária para mapeamento de Transaction
/// Centraliza a lógica de conversão entre Map e Transaction
class TransactionMapper {
  const TransactionMapper._();

  /// Converte um Map (do banco de dados) para Transaction
  static Transaction fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int,
      amountCents: map['amountCents'] as int,
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      category: map['category'] as String?,
      description: map['description'] as String?,
      humanDate: (map['humanDate'] as String?) ?? '',
      isRecurring: (map['isRecurring'] as int) == 1,
      createdAt: map['createdAt'] as int,
      targetMonth: map['targetMonth'] as int,
      targetYear: map['targetYear'] as int,
    );
  }

  /// Converte uma Transaction para Map (para persistência no banco)
  static Map<String, dynamic> toMap(Transaction transaction) {
    return {
      'amountCents': transaction.amountCents,
      'type': transaction.type == TransactionType.income ? 'income' : 'expense',
      'category': transaction.category,
      'description': transaction.description,
      'humanDate': transaction.humanDate,
      'isRecurring': transaction.isRecurring ? 1 : 0,
      'createdAt': transaction.createdAt,
      'targetMonth': transaction.targetMonth,
      'targetYear': transaction.targetYear,
    };
  }
}
