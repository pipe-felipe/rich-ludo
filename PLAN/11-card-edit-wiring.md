## BLOCK 11 — Add the pencil button and wire the edit flow into the main screen

**Depends on:** BLOCK 10 committed
**Touches:** `lib/presentation/ui/widgets/transaction_card.dart` (MODIFY), `lib/presentation/ui/widgets/transaction_list.dart` (MODIFY), `lib/presentation/ui/screens/main_screen.dart` (MODIFY), `test/presentation/ui/widgets/transaction_card_test.dart` (NEW)

4 files: the card's new `onEdit` callback has exactly one producer, `main_screen.dart`, reached
through `transaction_list.dart`. Splitting them across two blocks would leave the tree
uncompilable between the two commits.

### Goal
Every transaction card shows a pencil button beside its delete button; tapping it opens the
transaction dialog pre-filled with that transaction, and saving applies the edit — asking for the
scope first when the transaction is recurring, with `Este mês e anteriores` disabled whenever the
`Repete` switch was turned off.

### Context to read first
1. `lib/presentation/ui/widgets/transaction_card.dart` — the whole file (138 lines): the `Row` holding the icon, the details, the amount and the delete `IconButton`.
2. `lib/presentation/ui/screens/main_screen.dart:121-139` — `_showTransactionDialog`, which this block gives an `editing` parameter; and `:212-259` — `_TransactionContent` and `_handleDelete`, the shape `_handleEdit` mirrors.
3. `lib/presentation/ui/widgets/recurring_scope_dialog.dart` — `show(context, {required String title, Set<RecurringScope> disabledScopes = const {}})` as BLOCK 5 left it.
4. `test/presentation/ui/widgets/main_top_bar_test.dart:1-35` — the widget test style to mirror for a widget with no provider: a `pumpWidget` helper wrapping it in `MaterialApp` with `AppTheme.lightTheme()`, `AppLocalizations.localizationsDelegates` and `locale: const Locale('pt')`.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. In `lib/presentation/ui/widgets/transaction_card.dart`, add `import '../../../l10n/app_localizations.dart';` after the existing `transaction_type.dart` import, add the field `final VoidCallback onEdit;` after `customCategories`, and add `required this.onEdit,` to the constructor before `required this.onDelete,`.
2. In the same file, inside the `Row` of `build`, insert this `IconButton` immediately before the existing delete `IconButton`:
   ```dart
   IconButton(
     onPressed: onEdit,
     visualDensity: VisualDensity.compact,
     tooltip: AppLocalizations.of(context)!.transactionEditTooltip,
     icon: Icon(
       Icons.edit,
       color: Theme.of(context).colorScheme.onSurfaceVariant,
     ),
   ),
   ```
   and add `visualDensity: VisualDensity.compact,` to the existing delete `IconButton` so both buttons fit the row on a phone-width screen.
3. In `lib/presentation/ui/widgets/transaction_list.dart`, add the field `final void Function(Transaction) onEdit;` after `onDelete`, add `required this.onEdit,` to the constructor, and pass `onEdit: () => onEdit(item),` to `TransactionCard` beside the existing `onDelete`.
4. In `lib/presentation/ui/screens/main_screen.dart`, give `_showTransactionDialog` an `editing` parameter and add `_applyEdit` beside it, replacing the whole `_showTransactionDialog` method with these two methods:
   ```dart
   Future<void> _showTransactionDialog(
     BuildContext context,
     MainScreenViewModel viewModel, {
     Transaction? editing,
   }) async {
     final formViewModel = context.read<TransactionFormViewModel>();
     if (editing == null) {
       formViewModel.resetForm();
     } else {
       formViewModel.startEditing(editing);
     }

     await showDialog(
       context: context,
       builder: (dialogContext) => ChangeNotifierProvider.value(
         value: formViewModel,
         child: TransactionDialog(
           selectedMonth: viewModel.currentMonth,
           selectedYear: viewModel.currentYear,
           onSubmitEdit: editing == null
               ? null
               : (edited) =>
                     _applyEdit(dialogContext, viewModel, editing, edited),
         ),
       ),
     );
     formViewModel.resetForm();
     viewModel.invalidateAndReload();
   }

   Future<bool> _applyEdit(
     BuildContext context,
     MainScreenViewModel viewModel,
     Transaction original,
     Transaction edited,
   ) async {
     if (!original.isRecurring) {
       await viewModel.updateItem(edited);
       return true;
     }

     final l10n = AppLocalizations.of(context)!;
     // A one-off row cannot cover past months, so turning the Repete switch
     // off leaves "this month and previous" unreachable.
     final scope = await RecurringScopeDialog.show(
       context,
       title: l10n.recurringEditTitle,
       disabledScopes: edited.isRecurring
           ? const <RecurringScope>{}
           : const {RecurringScope.thisAndPreviousMonths},
     );
     if (scope == null) return false;

     await viewModel.updateRecurringItem(original, edited, scope);
     return true;
   }
   ```
5. In the same file, add `import '../../../domain/model/recurring_scope.dart';` to the import block, before the existing `import '../../../domain/model/transaction.dart';`.
6. In the same file, give `_TransactionContent` the field `final Future<void> Function(Transaction) onEdit;` after `customCategories`, add `required this.onEdit,` to its constructor, and pass `onEdit: onEdit,` to the `TransactionList` it builds.
7. In the same file, in `MainScreen.build`, pass the new callback where `_TransactionContent` is constructed:
   ```dart
   onEdit: (transaction) =>
       _showTransactionDialog(context, viewModel, editing: transaction),
   ```
8. Create `test/presentation/ui/widgets/transaction_card_test.dart` with a `pumpCard` helper taking a `Transaction` and two recording callbacks, and one `group('TransactionCard', ...)` holding exactly 4 test cases:
   - `'should show one edit button and one delete button'` — expect `find.byIcon(Icons.edit)` and `find.byIcon(Icons.delete)` to each find one widget.
   - `'should call onEdit when the pencil is tapped'` — tap `find.byIcon(Icons.edit)`, expect the edit callback to have run once and the delete callback not at all.
   - `'should call onDelete when the trash can is tapped'` — tap `find.byIcon(Icons.delete)`, expect the delete callback to have run once and the edit callback not at all.
   - `'should lay the row out without overflowing a phone width'` — set `tester.view.physicalSize` to `const Size(1080, 2400)` with `devicePixelRatio` `3.0`, reset both in `addTearDown`, pump a card whose `description` is `'Uma descrição bem longa de transação'` and `amountCents` is `123456789`, and expect `tester.takeException()` to be `isNull`.
9. Run the §5 write-only formatter on this block's paths only:
   ```
   dart format lib/presentation/ui/widgets/transaction_card.dart lib/presentation/ui/widgets/transaction_list.dart lib/presentation/ui/screens/main_screen.dart test/presentation/ui/widgets/transaction_card_test.dart
   ```

### Do not
- Do not add a color constant for the pencil. It uses `Theme.of(context).colorScheme.onSurfaceVariant`, which `AppTheme` already puts in both schemes (§9).
- Do not make the whole card tappable, add a long-press menu, or add a swipe action. The pencil is the only new affordance.
- Do not show the scope dialog for a transaction whose `original.isRecurring` is false, and do not skip it for one whose is true.
- Do not read `AppLocalizations` after an `await` inside `_applyEdit`; the `l10n` local is taken before the dialog opens, which is what the `use_build_context_synchronously` lint checks.
- Do not change `TransactionDialog`, the two update use cases, or `MainScreenViewModel`; they are finished.

### Verify
Run from the repository root, in this order:
```
flutter test test/presentation/ui/widgets/transaction_card_test.dart
flutter analyze
flutter test
```
Expected: the first command exits 0 and reports `+4` passing tests; the second exits 0 and prints
`No issues found!`; the third exits 0 and reports 334 passing tests, 0 failing.

### If verification fails
1. Read the failing output in full.
2. Fix only files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 11's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/presentation/ui/widgets/transaction_card.dart lib/presentation/ui/widgets/transaction_list.dart lib/presentation/ui/screens/main_screen.dart test/presentation/ui/widgets/transaction_card_test.dart PLAN.md
   git commit -m "Add the pencil button and wire the edit flow into the main screen"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.
