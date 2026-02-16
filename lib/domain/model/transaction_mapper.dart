import 'transaction.dart';
import 'transaction_type.dart';

class TransactionMapper {
  const TransactionMapper._();

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
