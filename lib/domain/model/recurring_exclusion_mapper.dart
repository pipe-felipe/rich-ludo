import 'recurring_exclusion.dart';

class RecurringExclusionMapper {
  const RecurringExclusionMapper._();

  static RecurringExclusion fromMap(Map<String, dynamic> map) {
    return RecurringExclusion(
      id: map['id'] as int,
      transactionId: map['transactionId'] as int,
      month: map['month'] as int,
      year: map['year'] as int,
    );
  }

  static Map<String, dynamic> toMap(RecurringExclusion exclusion) {
    return {
      'transactionId': exclusion.transactionId,
      'month': exclusion.month,
      'year': exclusion.year,
    };
  }
}
