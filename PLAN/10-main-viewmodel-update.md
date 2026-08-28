## BLOCK 10 — Add the update commands to the main ViewModel

**Depends on:** BLOCK 9 committed
**Touches:** `lib/presentation/viewmodel/main_screen_viewmodel.dart` (MODIFY), `test/presentation/viewmodel/main_screen_viewmodel_test.dart` (MODIFY), `lib/main.dart` (MODIFY)

### Goal
`MainScreenViewModel.updateItem(edited)` and
`MainScreenViewModel.updateRecurringItem(original, edited, scope)` write the change through the two
update use cases and reload the month afterwards.

### Context to read first
1. `lib/presentation/viewmodel/main_screen_viewmodel.dart:17-77` — the fields, the `Command` declarations and the constructor this block extends.
2. `lib/presentation/viewmodel/main_screen_viewmodel.dart:177-188` and `:345-369` — `_deleteItem`, `deleteItem` and `deleteRecurringItem`, the three shapes to mirror exactly: a `Command1` for the plain case, a direct `await` plus a `switch` on the `Result` for the scoped case, and `invalidateAndReload()` on success.
3. `test/presentation/viewmodel/main_screen_viewmodel_test.dart:1-100` — the mock classes, the `setUp` and the `createViewModel` helper this block extends; note the second direct construction at line 176.
4. `lib/main.dart:76-125` — the two delete use case providers and the `MainScreenViewModel` provider, the shape steps 10 and 11 extend. Both new constructor arguments are required, so `lib/main.dart` is part of this block: without it the tree stops compiling.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. In `lib/presentation/viewmodel/main_screen_viewmodel.dart`, add these two imports to the existing `../../domain/usecase/` block, keeping its alphabetical order:
   ```dart
   import '../../domain/usecase/update_recurring_transaction_usecase.dart';
   import '../../domain/usecase/update_transaction_usecase.dart';
   ```
2. Add two fields after `final DeleteRecurringTransactionUseCase _deleteRecurringTransactionUseCase;`:
   ```dart
   final UpdateTransactionUseCase _updateTransactionUseCase;
   final UpdateRecurringTransactionUseCase _updateRecurringTransactionUseCase;
   ```
3. Declare the command after `late final Command1<int, int> deleteTransaction;`:
   ```dart
   late final Command1<int, Transaction> updateTransaction;
   ```
4. Add the two constructor parameters after `deleteRecurringTransactionUseCase`:
   ```dart
   required UpdateTransactionUseCase updateTransactionUseCase,
   required UpdateRecurringTransactionUseCase updateRecurringTransactionUseCase,
   ```
   and the two initializers after `_deleteRecurringTransactionUseCase = deleteRecurringTransactionUseCase,`:
   ```dart
   _updateTransactionUseCase = updateTransactionUseCase,
   _updateRecurringTransactionUseCase = updateRecurringTransactionUseCase,
   ```
5. In the constructor body, immediately after `deleteTransaction = Command1<int, int>(_deleteItem);`, add:
   ```dart
   updateTransaction = Command1<int, Transaction>(_updateItem);
   ```
6. Add `_updateItem` immediately after the existing `_deleteItem` method, mirroring it:
   ```dart
   Future<Result<int>> _updateItem(Transaction transaction) async {
     final result = await _updateTransactionUseCase(transaction);

     switch (result) {
       case Ok<int>():
         break;
       case Error<int>():
         debugPrint('Error updating item: ${result.error}');
     }

     return result;
   }
   ```
7. Add the two public methods immediately after the existing `deleteRecurringItem` method:
   ```dart
   Future<void> updateItem(Transaction edited) async {
     await updateTransaction.execute(edited);
     if (updateTransaction.completed) {
       invalidateAndReload();
     }
   }

   Future<void> updateRecurringItem(
     Transaction original,
     Transaction edited,
     RecurringScope scope,
   ) async {
     final result = await _updateRecurringTransactionUseCase(
       original: original,
       edited: edited,
       scope: scope,
       currentMonth: _currentMonth,
       currentYear: _currentYear,
     );

     switch (result) {
       case Ok<int>():
         invalidateAndReload();
       case Error<int>():
         debugPrint('Error updating recurring: ${result.error}');
     }
   }
   ```
8. In `test/presentation/viewmodel/main_screen_viewmodel_test.dart`, add the two imports for the new use cases, declare two mocks next to the existing ones:
   ```dart
   class MockUpdateTransactionUseCase extends Mock
       implements UpdateTransactionUseCase {}

   class MockUpdateRecurringTransactionUseCase extends Mock
       implements UpdateRecurringTransactionUseCase {}
   ```
   declare the two `late` variables, create them in `setUp`, and pass them to **both**
   `MainScreenViewModel(` constructions — the one inside `createViewModel` and the one at line 176.
   Add `class FakeTransaction extends Fake implements Transaction {}` and a
   `setUpAll(() => registerFallbackValue(FakeTransaction()));` to the file.
9. In the same file, add one `group('Update', ...)` with exactly 3 test cases, each ending with `viewModel.dispose()`:
   - `'updateItem should call the update use case and reload'` — stub `mockUpdateTransactionUseCase(any())` to return `Result.ok(1)`, build the ViewModel through `createViewModel()`, `await waitForLoad(viewModel)`, call `await viewModel.updateItem(tx)` with a `Transaction(id: 1, amountCents: 100, type: TransactionType.expense, targetMonth: 8, targetYear: 2026)`, expect `verify(() => mockUpdateTransactionUseCase(any())).called(1)` and `viewModel.updateTransaction.completed` `isTrue`.
   - `'updateItem should report the error when the use case fails'` — stub it to return `Result.error(Exception('Database error'))`, expect `viewModel.updateTransaction.error` `isTrue`.
   - `'updateRecurringItem should pass the selected month and the scope'` — stub `mockUpdateRecurringTransactionUseCase(original: any(named: 'original'), edited: any(named: 'edited'), scope: any(named: 'scope'), currentMonth: any(named: 'currentMonth'), currentYear: any(named: 'currentYear'))` to return `Result.ok(1)`, call `await viewModel.updateRecurringItem(tx, tx, RecurringScope.thisMonth)`, and expect the captured `currentMonth` and `currentYear` to equal `viewModel.currentMonth` and `viewModel.currentYear`, and the captured `scope` to equal `RecurringScope.thisMonth`.
10. In `lib/main.dart`, add these two imports to the existing `domain/usecase/` block, keeping its alphabetical order:
    ```dart
    import 'domain/usecase/update_recurring_transaction_usecase.dart';
    import 'domain/usecase/update_transaction_usecase.dart';
    ```
    and register both use cases immediately after the `Provider<DeleteRecurringTransactionUseCase>` entry:
    ```dart
    Provider<UpdateTransactionUseCase>(
      create: (context) =>
          UpdateTransactionUseCase(context.read<TransactionRepository>()),
    ),
    Provider<UpdateRecurringTransactionUseCase>(
      create: (context) => UpdateRecurringTransactionUseCase(
        context.read<TransactionRepository>(),
      ),
    ),
    ```
11. In the same file, inside the `ChangeNotifierProvider<MainScreenViewModel>` entry, add these two arguments immediately after the `deleteRecurringTransactionUseCase:` argument:
    ```dart
    updateTransactionUseCase: context.read<UpdateTransactionUseCase>(),
    updateRecurringTransactionUseCase: context
        .read<UpdateRecurringTransactionUseCase>(),
    ```
12. Run the §5 write-only formatter on this block's paths only:
    ```
    dart format lib/presentation/viewmodel/main_screen_viewmodel.dart test/presentation/viewmodel/main_screen_viewmodel_test.dart lib/main.dart
    ```

### Do not
- Do not add a `Command3`, or wrap `updateRecurringItem` in a `Command`. `deleteRecurringItem` awaits its use case directly and this mirrors it (§9).
- Do not import `RecurringScope` from the delete use case file; import `../../domain/model/recurring_scope.dart`.
- Do not show a dialog, read `AppLocalizations`, or import anything from `lib/presentation/ui/widgets/` here. §7 rule 1 keeps a ViewModel free of widgets.
- Do not touch `lib/presentation/ui/screens/main_screen.dart` or any widget — that is BLOCK 11. `lib/main.dart` is in this block only because the two new constructor arguments are required.

### Verify
Run from the repository root, in this order:
```
flutter test test/presentation/viewmodel/main_screen_viewmodel_test.dart
flutter analyze
flutter test
```
Expected: the first command exits 0 and reports `+36` passing tests — 33 before this block plus the 3
added by step 9; the second exits 0 and prints `No issues found!`; the third exits 0 and reports 330
passing tests, 0 failing.

### If verification fails
1. Read the failing output in full.
2. Fix only files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 10's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/presentation/viewmodel/main_screen_viewmodel.dart test/presentation/viewmodel/main_screen_viewmodel_test.dart lib/main.dart PLAN.md
   git commit -m "Add the update commands to the main screen ViewModel and provide the use cases"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.
