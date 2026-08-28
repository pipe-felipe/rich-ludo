/// The span of months an operation on a recurring transaction applies to.
/// Shared by the delete flow and the edit flow.
enum RecurringScope {
  thisMonth,
  allMonths,
  thisAndPreviousMonths,
  thisAndFutureMonths,
}
