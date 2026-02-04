import 'transaction_type.dart';

/// Entidade de transação financeira
class Transaction {
  final int id;
  final int amountCents;
  final TransactionType type;
  final String? category;
  final String? description;
  final String humanDate;
  final bool isRecurring;
  final int createdAt;

  /// Mês alvo (1-12) onde esta transação pertence
  final int targetMonth;

  /// Ano alvo (ex: 2026) onde esta transação pertence
  final int targetYear;

  const Transaction({
    this.id = 0,
    required this.amountCents,
    required this.type,
    this.category,
    this.description,
    this.humanDate = '',
    this.isRecurring = false,
    this.createdAt = 0,
    this.targetMonth = 0,
    this.targetYear = 0,
  });

  Transaction copyWith({
    int? id,
    int? amountCents,
    TransactionType? type,
    String? category,
    String? description,
    String? humanDate,
    bool? isRecurring,
    int? createdAt,
    int? targetMonth,
    int? targetYear,
  }) {
    return Transaction(
      id: id ?? this.id,
      amountCents: amountCents ?? this.amountCents,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      humanDate: humanDate ?? this.humanDate,
      isRecurring: isRecurring ?? this.isRecurring,
      createdAt: createdAt ?? this.createdAt,
      targetMonth: targetMonth ?? this.targetMonth,
      targetYear: targetYear ?? this.targetYear,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.amountCents == amountCents &&
        other.type == type &&
        other.category == category &&
        other.description == description &&
        other.humanDate == humanDate &&
        other.isRecurring == isRecurring &&
        other.createdAt == createdAt &&
        other.targetMonth == targetMonth &&
        other.targetYear == targetYear;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      amountCents,
      type,
      category,
      description,
      humanDate,
      isRecurring,
      createdAt,
      targetMonth,
      targetYear,
    );
  }
}
