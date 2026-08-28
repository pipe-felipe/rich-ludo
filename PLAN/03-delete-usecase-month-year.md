## BLOCK 3 — Move the delete use case onto MonthYear

**Depends on:** BLOCK 2 committed
**Touches:** `lib/domain/usecase/delete_recurring_transaction_usecase.dart` (MODIFY)

### Goal
`DeleteRecurringTransactionUseCase` holds no month arithmetic of its own: `_isSingleMonth`,
`_isAfter`, `_isBefore`, `_nextMonth` and `_previousMonth` are gone and every call goes through
`MonthYear`, with its existing tests still green.

### Context to read first
1. `lib/domain/model/month_year.dart` — the whole file (created by BLOCK 1); `next`, `previous`, `isAfter`, `isBefore`.
2. `lib/domain/usecase/delete_recurring_transaction_usecase.dart` — the whole file; the five private helpers at the bottom and their call sites in `_deleteThisMonth`, `_deleteBackwards` and `_deleteForwards`.
3. `test/domain/usecase/delete_recurring_transaction_usecase_test.dart` — the tests that must stay green unchanged; this block changes no behaviour.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. Add `import '../model/month_year.dart';` to the import block, before the existing `import '../model/recurring_exclusion.dart';`.
2. Leave `_deleteThisMonth` unchanged: it already calls `_isSingleMonth`, which step 5 rewrites.
3. Replace the whole body of `_deleteBackwards` with:
   ```dart
   Future<Result<int>> _deleteBackwards(
     Transaction transaction,
     int month,
     int year,
   ) async {
     final next = MonthYear(month, year).next;
     final end = _endOf(transaction);

     if (end != null && next.isAfter(end)) {
       return _deleteAll(transaction.id);
     }

     final updated = transaction.copyWith(
       targetMonth: next.month,
       targetYear: next.year,
     );
     return _repository.updateTransaction(updated);
   }
   ```
4. Replace the whole body of `_deleteForwards` with:
   ```dart
   Future<Result<int>> _deleteForwards(
     Transaction transaction,
     int month,
     int year,
   ) async {
     final previous = MonthYear(month, year).previous;

     if (previous.isBefore(_startOf(transaction))) {
       return _deleteAll(transaction.id);
     }

     final updated = transaction.copyWith(
       endMonth: () => previous.month,
       endYear: () => previous.year,
     );
     return _repository.updateTransaction(updated);
   }
   ```
5. Delete the five private helpers `_isSingleMonth`, `_isAfter`, `_isBefore`, `_nextMonth` and `_previousMonth`, and put these three in their place at the bottom of the class:
   ```dart
   bool _isSingleMonth(Transaction tx, int month, int year) {
     final current = MonthYear(month, year);
     return _startOf(tx) == current && _endOf(tx) == current;
   }

   MonthYear _startOf(Transaction tx) =>
       MonthYear(tx.targetMonth, tx.targetYear);

   MonthYear? _endOf(Transaction tx) => tx.endMonth == null || tx.endYear == null
       ? null
       : MonthYear(tx.endMonth!, tx.endYear!);
   ```
6. Run the §5 write-only formatter on this block's path only:
   ```
   dart format lib/domain/usecase/delete_recurring_transaction_usecase.dart
   ```

### Do not
- Do not change one assertion, name or case in `test/domain/usecase/delete_recurring_transaction_usecase_test.dart`. This block keeps the behaviour identical; a red test here means the rewrite is wrong (§11 R6).
- Do not move `_startOf` and `_endOf` onto `Transaction` or onto `MonthYear`. BLOCK 7 declares its own copies in its own file; §9 tie-break allows the second occurrence and forbids extracting before the third.
- Do not touch `lib/presentation/` in this block.

### Verify
Run from the repository root, in this order:
```
grep -n "_nextMonth\|_previousMonth\|_isAfter\|_isBefore" lib/domain/usecase/delete_recurring_transaction_usecase.dart
flutter test test/domain/usecase/delete_recurring_transaction_usecase_test.dart
flutter analyze
```
Expected: the first command prints nothing and exits 1, which is `grep` reporting no match; the
second exits 0 and reports 9 passing tests, the same count as before this block; the third exits 0
and prints `No issues found!`.

### If verification fails
1. Read the failing output in full.
2. Fix only files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 3's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/domain/usecase/delete_recurring_transaction_usecase.dart PLAN.md
   git commit -m "Move the recurring delete rules onto MonthYear"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.
