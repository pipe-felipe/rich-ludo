## BLOCK 6 — Add UpdateTransactionUseCase

**Depends on:** BLOCK 5 committed
**Touches:** `lib/domain/usecase/update_transaction_usecase.dart` (NEW), `test/domain/usecase/update_transaction_usecase_test.dart` (NEW)

### Goal
`UpdateTransactionUseCase(repository)(transaction)` writes the transaction through
`TransactionRepository.updateTransaction` and returns its `Result<int>`.

### Context to read first
1. `lib/domain/usecase/delete_transaction_usecase.dart` — the whole file (9 lines): the exact shape to mirror, a single `call()` delegating to the repository.
2. `lib/domain/repository/transaction_repository.dart:17` — the `updateTransaction` signature this use case calls.
3. `test/domain/usecase/get_transactions_usecase_test.dart` — the unit test style to mirror for a delegating use case: a `Mock` of the repository, `when`/`verify`, `registerFallbackValue` in `setUpAll`.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. Create `lib/domain/usecase/update_transaction_usecase.dart` with exactly this content:
   ```dart
   import '../model/transaction.dart';
   import '../repository/transaction_repository.dart';
   import '../../utils/result.dart';

   class UpdateTransactionUseCase {
     final TransactionRepository _repository;

     UpdateTransactionUseCase(this._repository);

     Future<Result<int>> call(Transaction transaction) =>
         _repository.updateTransaction(transaction);
   }
   ```
2. Create `test/domain/usecase/update_transaction_usecase_test.dart` with `class MockTransactionRepository extends Mock implements TransactionRepository {}`, `class FakeTransaction extends Fake implements Transaction {}`, `registerFallbackValue(FakeTransaction())` in `setUpAll`, and one `group('UpdateTransactionUseCase', ...)` holding exactly 3 test cases:
   - `'should return Result.ok with the updated row count'` — stub `updateTransaction(any())` to return `Result.ok(1)`, call the use case with a `Transaction(id: 1, amountCents: 5000, type: TransactionType.expense)`, expect `result.isOk` `isTrue`, `result.asOk.value` equal to `1`, and `verify(() => mockRepository.updateTransaction(any())).called(1)`.
   - `'should pass the transaction through unchanged'` — stub as above, call with a `Transaction(id: 7, amountCents: 1234, type: TransactionType.income, category: 'salary', description: 'Bonus')`, capture the argument with `captureAny()` and expect its `id`, `amountCents`, `type`, `category` and `description` to match what was passed.
   - `'should return Result.error when the repository fails'` — stub `updateTransaction(any())` to return `Result.error(Exception('Database error'))`, expect `result.isError` `isTrue`.
3. Run the §5 write-only formatter on this block's paths only:
   ```
   dart format lib/domain/usecase/update_transaction_usecase.dart test/domain/usecase/update_transaction_usecase_test.dart
   ```

### Do not
- Do not delete exclusions here. Only the `allMonths` scope of BLOCK 7 clears them, and it does so in one place.
- Do not validate the transaction, guard on `id == 0`, or reload anything. `DeleteTransactionUseCase` does none of that and this use case mirrors it.
- Do not register this use case in `lib/main.dart` — that is BLOCK 12.

### Verify
Run from the repository root, in this order:
```
flutter test test/domain/usecase/update_transaction_usecase_test.dart
flutter analyze
```
Expected: the first command exits 0 and reports `+3` passing tests; the second exits 0 and prints
`No issues found!`.

### If verification fails
1. Read the failing output in full.
2. Fix only files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 6's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/domain/usecase/update_transaction_usecase.dart test/domain/usecase/update_transaction_usecase_test.dart PLAN.md
   git commit -m "Add UpdateTransactionUseCase"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.
