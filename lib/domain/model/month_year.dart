/// An immutable (month, year) pair with the arithmetic the recurring rules
/// need: one step in each direction, and ordering against another pair.
///
/// [month] is 1 to 12, matching `Transaction.targetMonth`.
class MonthYear implements Comparable<MonthYear> {
  final int month;
  final int year;

  const MonthYear(this.month, this.year);

  MonthYear get next =>
      month == 12 ? MonthYear(1, year + 1) : MonthYear(month + 1, year);

  MonthYear get previous =>
      month == 1 ? MonthYear(12, year - 1) : MonthYear(month - 1, year);

  bool isAfter(MonthYear other) => compareTo(other) > 0;

  bool isBefore(MonthYear other) => compareTo(other) < 0;

  @override
  int compareTo(MonthYear other) {
    return year != other.year
        ? year.compareTo(other.year)
        : month.compareTo(other.month);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonthYear && other.month == month && other.year == year;
  }

  @override
  int get hashCode => Object.hash(month, year);

  @override
  String toString() => 'MonthYear($month, $year)';
}
