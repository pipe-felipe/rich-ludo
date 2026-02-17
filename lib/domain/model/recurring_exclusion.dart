class RecurringExclusion {
  final int id;
  final int transactionId;
  final int month;
  final int year;

  const RecurringExclusion({
    this.id = 0,
    required this.transactionId,
    required this.month,
    required this.year,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecurringExclusion &&
        other.id == id &&
        other.transactionId == transactionId &&
        other.month == month &&
        other.year == year;
  }

  @override
  int get hashCode => Object.hash(id, transactionId, month, year);
}
