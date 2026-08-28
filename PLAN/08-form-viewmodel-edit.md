## BLOCK 8 — Give the form ViewModel an edit mode

**Depends on:** BLOCK 7 committed
**Touches:** `lib/presentation/viewmodel/transaction_form_viewmodel.dart` (MODIFY), `test/presentation/viewmodel/transaction_form_viewmodel_test.dart` (MODIFY)

### Goal
`TransactionFormViewModel.startEditing(transaction)` fills the form from a stored transaction,
`isEditing` reports that state, and `buildEditedTransaction()` returns that transaction carrying the
values currently in the form.

### Context to read first
1. `lib/presentation/viewmodel/transaction_form_viewmodel.dart` — the whole file (180 lines): `FormUiState`, `_uiState`, `_submitTransaction` and `resetForm`.
2. `lib/domain/model/transaction.dart:36-64` — the `copyWith` signature; `endMonth` and `endYear` take `int? Function()?`, every other field takes a plain nullable value.
3. `lib/presentation/ui/utils/money_formatter.dart` — `formatMoney(int)` renders cents as `50.00`, which `double.tryParse` reads back. `lib/presentation/viewmodel/main_screen_viewmodel.dart:15` shows a ViewModel already importing it.
4. `test/presentation/viewmodel/transaction_form_viewmodel_test.dart` — the test style to mirror, and the `group('resetForm')` at its end that step 6 extends.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. In `lib/presentation/viewmodel/transaction_form_viewmodel.dart`, add `import '../ui/utils/money_formatter.dart';` after the existing `import '../../utils/result.dart';`.
2. Inside `TransactionFormViewModel`, immediately after the field `FormUiState _uiState = const FormUiState();`, add:
   ```dart
   Transaction? _editingTransaction;
   ```
   and immediately after the getter `FormUiState get uiState => _uiState;`, add:
   ```dart
   /// The stored transaction the form is editing, or null while the form
   /// creates a new one.
   Transaction? get editingTransaction => _editingTransaction;

   bool get isEditing => _editingTransaction != null;
   ```
3. Immediately after the `isEditing` getter, add:
   ```dart
   /// Fills the form from [transaction] so the dialog opens on its stored
   /// values, and puts the form in edit mode.
   void startEditing(Transaction transaction) {
     _editingTransaction = transaction;
     _uiState = FormUiState(
       date: transaction.humanDate,
       transactionType: transaction.type,
       categorySlug: transaction.category,
       quantity: formatMoney(transaction.amountCents),
       notes: transaction.description ?? '',
       isRecurring: transaction.isRecurring,
     );
     notifyListeners();
   }

   /// The edited transaction, or null while the form is not editing. It keeps
   /// the stored row's `id`, `createdAt`, `humanDate`, `targetMonth`,
   /// `targetYear`, `endMonth` and `endYear`; the use cases decide what a scope
   /// does to the last four.
   Transaction? buildEditedTransaction() {
     final original = _editingTransaction;
     if (original == null) return null;

     return original.copyWith(
       amountCents: _amountCents,
       type: _uiState.transactionType,
       category: _uiState.categorySlug,
       description: _uiState.notes,
       isRecurring: _uiState.isRecurring,
     );
   }

   int get _amountCents {
     final normalizedQuantity = _uiState.quantity.replaceAll(',', '.');
     final amountDouble = double.tryParse(normalizedQuantity) ?? 0.0;
     return (amountDouble * 100).round();
   }
   ```
4. In `_submitTransaction`, delete these three lines
   ```dart
   final normalizedQuantity = _uiState.quantity.replaceAll(',', '.');
   final amountDouble = double.tryParse(normalizedQuantity) ?? 0.0;
   final amountCents = (amountDouble * 100).round();
   ```
   and replace them with:
   ```dart
   final amountCents = _amountCents;
   ```
5. In `resetForm`, add `_editingTransaction = null;` as the first statement, before `_uiState = const FormUiState();`.
6. In `test/presentation/viewmodel/transaction_form_viewmodel_test.dart`, add `import 'package:rich_ludo/domain/model/transaction.dart';` if it is absent, a `storedTransaction` helper before the groups:
   ```dart
   Transaction storedTransaction({
     int amountCents = 5000,
     bool isRecurring = false,
   }) {
     return Transaction(
       id: 42,
       amountCents: amountCents,
       type: TransactionType.expense,
       category: 'food',
       description: 'Lunch',
       humanDate: '2026-08-04',
       isRecurring: isRecurring,
       createdAt: 1754006400000,
       targetMonth: 8,
       targetYear: 2026,
     );
   }
   ```
   and two new groups inside `group('TransactionFormViewModel', ...)`, holding exactly 7 test cases:
   - `group('startEditing')`
     - `'should fill the form from the stored transaction'` — call `viewModel.startEditing(storedTransaction())`; expect `uiState.transactionType` `TransactionType.expense`, `categorySlug` `'food'`, `quantity` `'50.00'`, `notes` `'Lunch'`, `date` `'2026-08-04'`, `isRecurring` `isFalse`.
     - `'should report isEditing and expose the stored transaction'` — expect `viewModel.isEditing` `isTrue` and `viewModel.editingTransaction!.id` equal to `42`.
     - `'should enable submit right away'` — expect `viewModel.isSubmitEnabled` `isTrue`.
   - `group('buildEditedTransaction')`
     - `'should return null when the form is not editing'` — expect `viewModel.buildEditedTransaction()` `isNull`.
     - `'should keep the id, createdAt, humanDate, month and year of the stored row'` — after `startEditing(storedTransaction())` and `onQuantityChange('99')`, expect the built transaction's `id` `42`, `createdAt` `1754006400000`, `humanDate` `'2026-08-04'`, `targetMonth` `8`, `targetYear` `2026`.
     - `'should carry the edited amount, type, category, notes and recurring flag'` — after `startEditing(storedTransaction())`, `onQuantityChange('12,50')`, `onNotesChange('Dinner')`, `onRecurringChange(true)`, expect the built transaction's `amountCents` `1250`, `category` `'food'`, `description` `'Dinner'`, `isRecurring` `isTrue`.
     - `'should carry the category chosen after a type change'` — after `startEditing(storedTransaction())`, `onTransactionTypeChange(TransactionType.income)`, `onCategoryChange('salary')`, expect the built transaction's `type` `TransactionType.income` and `category` `'salary'`.
   Then add one test to the existing `group('resetForm')`:
   - `'should leave edit mode'` — `startEditing(storedTransaction())`, `resetForm()`, expect `viewModel.isEditing` `isFalse` and `viewModel.buildEditedTransaction()` `isNull`.
7. Run the §5 write-only formatter on this block's paths only:
   ```
   dart format lib/presentation/viewmodel/transaction_form_viewmodel.dart test/presentation/viewmodel/transaction_form_viewmodel_test.dart
   ```

### Do not
- Do not add a second ViewModel or a second UI-state class for editing; §9 keeps the edit state inside `TransactionFormViewModel` and `FormUiState`.
- Do not add an update use case to this ViewModel's constructor. The screen decides between the two update use cases because only it can show the scope dialog; wiring is BLOCK 10 and BLOCK 12.
- Do not add a guard to `_submitTransaction` that refuses to run in edit mode. The dialog never calls it there, and §11 R9 forbids branches the steps do not name.
- Do not write `_editingTransaction!`. `buildEditedTransaction` reads it into a local and returns null.

### Verify
Run from the repository root, in this order:
```
flutter test test/presentation/viewmodel/transaction_form_viewmodel_test.dart
flutter analyze
```
Expected: the first command exits 0 and reports `+35` passing tests — 27 before this block plus the
8 added by step 6; the second exits 0 and prints `No issues found!`.

### If verification fails
1. Read the failing output in full.
2. Fix only files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 8's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/presentation/viewmodel/transaction_form_viewmodel.dart test/presentation/viewmodel/transaction_form_viewmodel_test.dart PLAN.md
   git commit -m "Give the transaction form ViewModel an edit mode"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.
