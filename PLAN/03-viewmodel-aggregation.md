## BLOCK 3 — Aggregate expenses by category in the ViewModel

**Depends on:** BLOCK 2 committed
**Touches:** `lib/presentation/viewmodel/main_screen_viewmodel.dart` (MODIFY), `test/presentation/viewmodel/main_screen_viewmodel_test.dart` (MODIFY), `AGENTS.md` (MODIFY)

3 files: the ViewModel, its test, and a one-line correction to `AGENTS.md:50` that the user
approved during planning (§7 NOTE).

### Goal
`MainScreenViewModel.expenseByCategory` returns the selected month's expenses grouped by
`Transaction.category`, sorted by amount descending, and is emptied when the user navigates to
another month.

### Context to read first
1. `lib/presentation/viewmodel/main_screen_viewmodel.dart:187-195` — `_filterAndComputeTotals()`, where the aggregation is added.
2. `lib/presentation/viewmodel/main_screen_viewmodel.dart:231-235` — `_sumByType()`, the sibling helper whose shape the new helper mirrors.
3. `lib/presentation/viewmodel/main_screen_viewmodel.dart:312-319` — `_clearSelectedMonthData()`, where the aggregation is emptied.
4. `test/presentation/viewmodel/main_screen_viewmodel_test.dart:59-105` — the `createViewModel()` and `waitForLoad()` helpers every new test reuses.
5. `test/presentation/viewmodel/main_screen_viewmodel_test.dart:691-748` — the `group('Selected month summary', ...)` tests; the new group is written in the same style.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. In `lib/presentation/viewmodel/main_screen_viewmodel.dart`, after the import line
   `import '../../domain/model/transaction.dart';`, insert:
   ```dart
   import '../../domain/model/category_total.dart';
   ```
   Then move that new line above `import '../../domain/model/recurring_exclusion.dart';` so the
   `domain/model` imports stay alphabetically ordered, matching the existing import block.
2. In the same file, after the field declaration `int _totalExpenseCents = 0;`, insert:
   ```dart
   List<CategoryTotal> _expenseByCategory = [];
   ```
3. In the same file, after the getter `int get totalExpenseCents => _totalExpenseCents;`, insert:
   ```dart
   List<CategoryTotal> get expenseByCategory => _expenseByCategory;
   ```
4. In `_filterAndComputeTotals()`, immediately after the line
   `_totalExpenseCents = _sumByType(_items, TransactionType.expense);`, insert:
   ```dart
   _expenseByCategory = _groupExpensesByCategory(_items);
   ```
5. In the same file, immediately after the closing brace of `_sumByType()`, insert:
   ```dart
   List<CategoryTotal> _groupExpensesByCategory(List<Transaction> items) {
     final totalsByCategory = <String?, int>{};

     for (final tx in items) {
       if (tx.type != TransactionType.expense) continue;
       totalsByCategory[tx.category] =
           (totalsByCategory[tx.category] ?? 0) + tx.amountCents;
     }

     final totals = totalsByCategory.entries
         .map(
           (entry) =>
               CategoryTotal(category: entry.key, amountCents: entry.value),
         )
         .toList();
     totals.sort((a, b) => b.amountCents.compareTo(a.amountCents));
     return totals;
   }
   ```
6. In `_clearSelectedMonthData()`, immediately after the line `_totalExpenseCents = 0;`, insert:
   ```dart
   _expenseByCategory = [];
   ```
7. In `test/presentation/viewmodel/main_screen_viewmodel_test.dart`, add the import
   `import 'package:rich_ludo/domain/model/category_total.dart';` immediately after the existing
   line `import 'package:rich_ludo/domain/model/transaction.dart';`.
8. In the same test file, immediately before the line `group('Navigation race', () {`, insert a
   new `group('Expenses by category', () { ... });` containing exactly these 6 tests, each built
   with `createViewModel(...)`, awaited with `await waitForLoad(viewModel);`, and ending with
   `viewModel.dispose();`, exactly like the neighbouring groups:
   - `'should group expenses by category for the selected month'` — load 3 expenses in the current month: `'food'` 1000, `'food'` 500, `'transport'` 700. Expect `viewModel.expenseByCategory` has length 2, and contains `const CategoryTotal(category: 'food', amountCents: 1500)`.
   - `'should ignore income when grouping'` — load 1 income of 9000 with category `'salary'` and 1 expense of 300 with category `'food'`. Expect `viewModel.expenseByCategory.single` equals `const CategoryTotal(category: 'food', amountCents: 300)`.
   - `'should group expenses without a category under a null key'` — load 2 expenses with `category: null` of 100 and 250. Expect `viewModel.expenseByCategory.single` equals `const CategoryTotal(category: null, amountCents: 350)`.
   - `'should sort categories by amount descending'` — load expenses `'food'` 100, `'transport'` 900, `'gift'` 400. Expect `viewModel.expenseByCategory.map((total) => total.category).toList()` equals `['transport', 'gift', 'food']`.
   - `'should be empty when the month has no expenses'` — load 1 income only. Expect `viewModel.expenseByCategory`, `isEmpty`.
   - `'should clear the grouping when navigating to another month'` — load 1 expense of 800 with category `'food'`, assert `viewModel.expenseByCategory` is not empty, then call `viewModel.goToNextMonth()` and assert `viewModel.expenseByCategory` is `isEmpty` **without** awaiting the load, mirroring the assertions in the existing `group('Navigation race', ...)` test.
9. In `AGENTS.md`, replace the line
   `- **Nomes**: Em português: \`test('deve retornar X quando Y', ...)\`` with:
   ```markdown
   - **Nomes**: Em inglês: `test('should return X when Y', ...)`
   ```
10. Format the two Dart files:
    ```
    dart format lib/presentation/viewmodel/main_screen_viewmodel.dart test/presentation/viewmodel/main_screen_viewmodel_test.dart
    ```

### Do not
- Do not call `_getTransactionsUseCase`, `_getExclusionsUseCase`, or any repository from the new helper. It reads only the `items` list it is given.
- Do not add a `GetExpensesByCategoryUseCase` — §9 forbids it.
- Do not touch `_computeSavingsCents()`, `_recurringContributionToSavings()`, `_visibleItemsForMonth()`, `_isRecurringActiveInMonth()`, or `_isExcludedInMonth()` (§7 rule 7).
- Do not add an `_expenseByCategoryText` string field; formatting belongs to the widgets.
- Do not rewrite existing Portuguese test names in the file to English; only new tests are English.
- Do not run `dart format` on any path other than the two named in step 10.

### Verify
Run from the repository root, in this order:
```
flutter test test/presentation/viewmodel/main_screen_viewmodel_test.dart
flutter test
flutter analyze
```
Expected: the first command exits 0 and prints `+33: All tests passed!` (27 from §6 Baseline
plus 6 new); the second exits 0 and prints `+183: All tests passed!` (172 from §6 Baseline plus
5 from BLOCK 2 plus 6 new); `flutter analyze` exits 0 printing `No issues found!`.

### If verification fails
1. Read the failing output in full.
2. Fix only files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 3's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/presentation/viewmodel/main_screen_viewmodel.dart test/presentation/viewmodel/main_screen_viewmodel_test.dart AGENTS.md PLAN.md
   git commit -m "Group the selected month expenses by category in the ViewModel"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.
