## BLOCK 7 — Add UpdateRecurringTransactionUseCase

**Depends on:** BLOCK 6 committed
**Touches:** `lib/domain/usecase/update_recurring_transaction_usecase.dart` (NEW), `test/domain/usecase/update_recurring_transaction_usecase_test.dart` (NEW)

### Goal
`UpdateRecurringTransactionUseCase` applies an edit to a recurring transaction over one of the four
`RecurringScope` spans, exactly as the table in §1 states.

### Context to read first
1. §1 — the scope table. It is the specification this block implements; step 1 is its literal translation.
2. `lib/domain/usecase/delete_recurring_transaction_usecase.dart` — the whole file as BLOCK 3 left it: the `switch` over `RecurringScope`, the private per-scope methods, `_startOf`, `_endOf`, `_isSingleMonth`.
3. `test/domain/usecase/delete_recurring_transaction_usecase_test.dart` — the test style to mirror: `FakeTransactionRepository` from `test/fakes/`, a `createRecurring` helper, one `group` per scope.
4. `test/fakes/fake_transaction_repository.dart` — the fake's behaviour: `makeTransaction` assigns `id = _transactions.length + 1`, `updateTransaction` replaces the row with the matching id, `getTransactions` and `getExclusions` return the stored lists.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. Create `lib/domain/usecase/update_recurring_transaction_usecase.dart` with exactly this content:
   ```dart
   import '../model/month_year.dart';
   import '../model/recurring_exclusion.dart';
   import '../model/recurring_scope.dart';
   import '../model/transaction.dart';
   import '../repository/transaction_repository.dart';
   import '../../utils/result.dart';

   /// Applies an edit to a recurring transaction over the span of months the
   /// user chose. [original] is the stored row; [edited] carries the new values
   /// and keeps the original `id`, `createdAt` and `humanDate`.
   ///
   /// [RecurringScope.thisAndPreviousMonths] is reachable only while
   /// `edited.isRecurring` is true: a one-off row cannot cover past months, so
   /// the dialog disables that option when the user turns repetition off.
   class UpdateRecurringTransactionUseCase {
     final TransactionRepository _repository;

     UpdateRecurringTransactionUseCase(this._repository);

     Future<Result<int>> call({
       required Transaction original,
       required Transaction edited,
       required RecurringScope scope,
       required int currentMonth,
       required int currentYear,
     }) async {
       final current = MonthYear(currentMonth, currentYear);

       switch (scope) {
         case RecurringScope.allMonths:
           return _updateWholeRule(original, edited);

         case RecurringScope.thisMonth:
           return _updateThisMonth(original, edited, current);

         case RecurringScope.thisAndPreviousMonths:
           return _updateBackwards(original, edited, current);

         case RecurringScope.thisAndFutureMonths:
           return _updateForwards(original, edited, current);
       }
     }

     Future<Result<int>> _updateWholeRule(
       Transaction original,
       Transaction edited,
     ) async {
       if (!edited.isRecurring) {
         await _repository.deleteExclusionsForTransaction(original.id);
       }
       return _repository.updateTransaction(edited);
     }

     Future<Result<int>> _updateThisMonth(
       Transaction original,
       Transaction edited,
       MonthYear current,
     ) async {
       if (_isSingleMonth(original, current)) {
         return _updateWholeRule(original, edited);
       }

       final excluded = await _repository.addExclusion(
         RecurringExclusion(
           transactionId: original.id,
           month: current.month,
           year: current.year,
         ),
       );
       if (excluded.isError) return Result.error(excluded.asError.error);

       return _insertCopy(edited, start: current, end: null, isRecurring: false);
     }

     Future<Result<int>> _updateBackwards(
       Transaction original,
       Transaction edited,
       MonthYear current,
     ) async {
       final next = current.next;
       final end = _endOf(original);

       if (end != null && next.isAfter(end)) {
         return _updateWholeRule(original, edited);
       }

       final moved = await _repository.updateTransaction(
         original.copyWith(targetMonth: next.month, targetYear: next.year),
       );
       if (moved.isError) return moved;

       return _insertCopy(
         edited,
         start: _startOf(original),
         end: current,
         isRecurring: true,
       );
     }

     Future<Result<int>> _updateForwards(
       Transaction original,
       Transaction edited,
       MonthYear current,
     ) async {
       final previous = current.previous;

       if (previous.isBefore(_startOf(original))) {
         return _updateWholeRule(original, edited);
       }

       final truncated = await _repository.updateTransaction(
         original.copyWith(
           endMonth: () => previous.month,
           endYear: () => previous.year,
         ),
       );
       if (truncated.isError) return truncated;

       return _insertCopy(
         edited,
         start: current,
         end: edited.isRecurring ? _endOf(original) : null,
         isRecurring: edited.isRecurring,
       );
     }

     Future<Result<int>> _insertCopy(
       Transaction edited, {
       required MonthYear start,
       required MonthYear? end,
       required bool isRecurring,
     }) {
       return _repository.makeTransaction(
         edited.copyWith(
           id: 0,
           isRecurring: isRecurring,
           targetMonth: start.month,
           targetYear: start.year,
           endMonth: () => end?.month,
           endYear: () => end?.year,
         ),
       );
     }

     bool _isSingleMonth(Transaction tx, MonthYear current) =>
         _startOf(tx) == current && _endOf(tx) == current;

     MonthYear _startOf(Transaction tx) =>
         MonthYear(tx.targetMonth, tx.targetYear);

     MonthYear? _endOf(Transaction tx) => tx.endMonth == null || tx.endYear == null
         ? null
         : MonthYear(tx.endMonth!, tx.endYear!);
   }
   ```
2. Create `test/domain/usecase/update_recurring_transaction_usecase_test.dart`. Use `FakeTransactionRepository` from `../../fakes/fake_transaction_repository.dart`, and declare two helpers at the top of `main()`:
   ```dart
   Transaction createRecurring({
     int id = 1,
     int targetMonth = 3,
     int targetYear = 2026,
     int? endMonth,
     int? endYear,
   }) {
     return Transaction(
       id: id,
       amountCents: 5000,
       type: TransactionType.expense,
       category: 'food',
       isRecurring: true,
       targetMonth: targetMonth,
       targetYear: targetYear,
       endMonth: endMonth,
       endYear: endYear,
     );
   }

   Transaction edit(Transaction original, {bool isRecurring = true}) {
     return original.copyWith(amountCents: 9900, isRecurring: isRecurring);
   }
   ```
3. In the same file write one `group('UpdateRecurringTransactionUseCase', ...)` with five nested groups holding exactly 11 test cases. Every case seeds the fake with `fakeRepository.addTransaction(tx)` and calls the use case with `currentMonth: 5, currentYear: 2026`.
   - `group('allMonths')`
     - `'should write the edited values onto the stored row'` — original `createRecurring()`, edited `edit(tx)`; expect `result.isOk` `isTrue`, the fake to hold exactly 1 transaction, and its `amountCents` to equal `9900`.
     - `'should clear the exclusions when repetition is turned off'` — seed an exclusion with `fakeRepository.addExclusion(const RecurringExclusion(transactionId: 1, month: 4, year: 2026))`, edited `edit(tx, isRecurring: false)`; expect the fake's exclusions to be empty and the stored row's `isRecurring` to be `isFalse`.
   - `group('thisMonth')`
     - `'should exclude the current month and insert a one-off copy'` — original `createRecurring()`; expect exactly 1 exclusion with `month` `5` and `year` `2026`, the fake to hold 2 transactions, and the second one to have `amountCents` `9900`, `isRecurring` `isFalse`, `targetMonth` `5`, `targetYear` `2026`, `endMonth` `isNull` and `endYear` `isNull`.
     - `'should keep the original row untouched'` — same setup; expect the transaction with `id` `1` to still have `amountCents` `5000`, `targetMonth` `3` and `isRecurring` `isTrue`.
     - `'should update the row in place when the rule spans only this month'` — original `createRecurring(targetMonth: 5, targetYear: 2026, endMonth: 5, endYear: 2026)`; expect the fake to hold exactly 1 transaction with `amountCents` `9900`, and no exclusion.
   - `group('thisAndPreviousMonths')`
     - `'should move the original start past the current month'` — original `createRecurring()`; expect the transaction with `id` `1` to have `targetMonth` `6` and `targetYear` `2026`.
     - `'should insert a recurring copy covering the original start through this month'` — same setup; expect the fake to hold 2 transactions and the second to have `amountCents` `9900`, `isRecurring` `isTrue`, `targetMonth` `3`, `targetYear` `2026`, `endMonth` `5` and `endYear` `2026`.
     - `'should update the row in place when nothing is left after this month'` — original `createRecurring(endMonth: 5, endYear: 2026)`; expect the fake to hold exactly 1 transaction with `amountCents` `9900` and `targetMonth` `3`.
   - `group('thisAndFutureMonths')`
     - `'should end the original at the previous month and insert a recurring copy'` — original `createRecurring(endMonth: 12, endYear: 2026)`; expect the transaction with `id` `1` to have `endMonth` `4` and `endYear` `2026`, the fake to hold 2 transactions, and the second to have `isRecurring` `isTrue`, `targetMonth` `5`, `targetYear` `2026`, `endMonth` `12` and `endYear` `2026`.
     - `'should insert a one-off copy when repetition is turned off'` — original `createRecurring(endMonth: 12, endYear: 2026)`, edited `edit(tx, isRecurring: false)`; expect the second transaction to have `isRecurring` `isFalse`, `targetMonth` `5`, `endMonth` `isNull` and `endYear` `isNull`.
     - `'should update the row in place when nothing is left before this month'` — original `createRecurring(targetMonth: 5, targetYear: 2026)`; expect the fake to hold exactly 1 transaction with `amountCents` `9900` and `endMonth` `isNull`.
   - `group('errors')`
     - `'should return Result.error when the repository fails'` — original `createRecurring()`, set `fakeRepository.shouldReturnError = true`, scope `RecurringScope.allMonths`; expect `result.isError` `isTrue`.
4. Run the §5 write-only formatter on this block's paths only:
   ```
   dart format lib/domain/usecase/update_recurring_transaction_usecase.dart test/domain/usecase/update_recurring_transaction_usecase_test.dart
   ```

### Do not
- Do not move an exclusion of the original onto an inserted copy; §3 puts that out of scope and the delete flow leaves them behind the same way.
- Do not change `id`, `createdAt` or `humanDate` on any row. `_insertCopy` sets `id: 0` only so the caller sees a fresh row; `TransactionMapper.toMap` omits `id`, so SQLite assigns it.
- Do not call `MakeTransactionUseCase`. It reactivates excluded recurring rows, which would undo the exclusion `_updateThisMonth` just wrote. Insert through `TransactionRepository.makeTransaction`.
- Do not add a fifth scope, a dry-run mode, or an options object.
- Do not modify `test/fakes/fake_transaction_repository.dart`; it already implements every method this block calls.

### Verify
Run from the repository root, in this order:
```
flutter test test/domain/usecase/update_recurring_transaction_usecase_test.dart
flutter test test/domain/usecase/delete_recurring_transaction_usecase_test.dart
flutter analyze
```
Expected: the first command exits 0 and reports `+11` passing tests; the second exits 0 and reports
`+9`; the third exits 0 and prints `No issues found!`.

### If verification fails
1. Read the failing output in full.
2. Fix only files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 7's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/domain/usecase/update_recurring_transaction_usecase.dart test/domain/usecase/update_recurring_transaction_usecase_test.dart PLAN.md
   git commit -m "Add UpdateRecurringTransactionUseCase"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.
