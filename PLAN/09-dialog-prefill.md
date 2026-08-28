## BLOCK 9 — Pre-fill the transaction dialog and route its edit submit

**Depends on:** BLOCK 8 committed
**Touches:** `lib/presentation/ui/widgets/transaction_dialog.dart` (MODIFY), `test/presentation/ui/widgets/transaction_dialog_test.dart` (MODIFY)

### Goal
When `TransactionFormViewModel.isEditing` is true, `TransactionDialog` opens showing the stored
amount and notes in its text fields, and its submit button calls the `onSubmitEdit` callback instead
of `viewModel.submit`, closing only when that callback returns true.

### Context to read first
1. `lib/presentation/ui/widgets/transaction_dialog.dart` — the whole file (429 lines). The quantity `TextField` lives inside `_CategoryAndQuantityInput`, the notes one inside `_NotesInput`; neither has a controller today, so neither can show a stored value.
2. `lib/presentation/ui/widgets/transaction_dialog.dart:274-297` — `_CategoryDropdown`, the file's existing `StatefulWidget` pattern: `State` class named `_CategoryDropdownState`, fields read through `widget.`.
3. `test/presentation/ui/widgets/transaction_dialog_test.dart` — the whole file (157 lines): the `openTransactionDialog` helper and how it builds the two providers. Its `home:` puts the dialog straight into a `Scaffold` body, so `Navigator.pop` has no route to remove; step 7 adds a second helper that pushes the dialog instead.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. Add `import '../../../domain/model/transaction.dart';` to the import block of `lib/presentation/ui/widgets/transaction_dialog.dart`, before the existing `import '../../../domain/model/transaction_type.dart';`.
2. Give `TransactionDialog` a third field after `selectedYear`:
   ```dart
   /// Called instead of the create path when the form is editing a stored
   /// transaction. Returns true when the edit was applied and the dialog may
   /// close, false when the user backed out of the scope dialog.
   final Future<bool> Function(Transaction edited)? onSubmitEdit;
   ```
   and add `this.onSubmitEdit,` as an optional named parameter at the end of the constructor.
3. Replace the `onSubmit` callback passed to `_ActionsBar` with:
   ```dart
   onSubmit: () async {
     if (viewModel.isEditing) {
       final edited = viewModel.buildEditedTransaction();
       if (edited == null) return;
       final applied = await onSubmitEdit?.call(edited) ?? false;
       if (!applied) return;
     } else {
       await viewModel.submit(selectedMonth, selectedYear);
     }
     if (context.mounted) {
       Navigator.of(context).pop();
     }
   },
   ```
4. Replace the quantity `TextField` inside `_CategoryAndQuantityInput.build` with `_QuantityInput(initialQuantity: uiState.quantity, isQuantityError: uiState.isQuantityError, onQuantityChange: onQuantityChange)`, keeping the surrounding `Expanded`.
5. Add the `_QuantityInput` widget immediately after the `_CategoryAndQuantityInput` class:
   ```dart
   class _QuantityInput extends StatefulWidget {
     final String initialQuantity;
     final bool isQuantityError;
     final void Function(String) onQuantityChange;

     const _QuantityInput({
       required this.initialQuantity,
       required this.isQuantityError,
       required this.onQuantityChange,
     });

     @override
     State<_QuantityInput> createState() => _QuantityInputState();
   }

   class _QuantityInputState extends State<_QuantityInput> {
     late final TextEditingController _controller = TextEditingController(
       text: widget.initialQuantity,
     );

     @override
     void dispose() {
       _controller.dispose();
       super.dispose();
     }

     @override
     Widget build(BuildContext context) {
       final l10n = AppLocalizations.of(context)!;

       return TextField(
         controller: _controller,
         decoration: InputDecoration(
           labelText: l10n.formQuantityLabel,
           border: const OutlineInputBorder(),
           errorText: widget.isQuantityError ? l10n.labelInvalidNumber : null,
         ),
         keyboardType: const TextInputType.numberWithOptions(decimal: true),
         inputFormatters: [
           FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
         ],
         onChanged: widget.onQuantityChange,
       );
     }
   }
   ```
6. Turn `_NotesInput` into a `StatefulWidget` with the same shape: rename its `notes` field to `initialNotes`, keep `onNotesChange`, and move its `build` into `_NotesInputState`, which owns
   `late final TextEditingController _controller = TextEditingController(text: widget.initialNotes);`,
   disposes it, and passes `controller: _controller` and `onChanged: widget.onNotesChange` to the
   `TextField`. Update its call site in `TransactionDialog.build` to `_NotesInput(initialNotes: uiState.notes, onNotesChange: viewModel.onNotesChange)`.
7. In `test/presentation/ui/widgets/transaction_dialog_test.dart`, leave the existing `openTransactionDialog` helper and its three tests exactly as they are, and add a second helper `pumpEditDialog` beside it. It takes a `Transaction editing` and a `Future<bool> Function(Transaction) onSubmitEdit`, builds the same two ViewModels the existing helper builds, calls `formViewModel.startEditing(editing)`, and pumps the dialog through a pushed route so `Navigator.pop` has a route to remove:
   ```dart
   home: Scaffold(
     body: Builder(
       builder: (context) => ElevatedButton(
         onPressed: () => showDialog<void>(
           context: context,
           builder: (_) => TransactionDialog(
             selectedMonth: 8,
             selectedYear: 2026,
             onSubmitEdit: onSubmitEdit,
           ),
         ),
         child: const Text('open'),
       ),
     ),
   ),
   ```
   The helper ends with `await tester.tap(find.text('open')); await tester.pumpAndSettle();`. Wrap
   that `Scaffold` in the same `MultiProvider` and `MaterialApp` the existing helper uses, with
   `ChangeNotifierProvider<TransactionFormViewModel>.value` above the `showDialog` builder so the
   dialog's `Consumer` finds it.
8. In the same file, add one `group('TransactionDialog edit mode', ...)` with exactly 3 test cases, each passing an `editing` transaction built as `Transaction(id: 42, amountCents: 5000, type: TransactionType.expense, category: 'food', description: 'Lunch', humanDate: '2026-08-04', targetMonth: 8, targetYear: 2026)`:
   - `'should show the stored amount and notes'` — pass a callback returning `true`; expect `find.widgetWithText(TextField, '50.00')` and `find.widgetWithText(TextField, 'Lunch')` to each find one widget.
   - `'should call onSubmitEdit with the edited transaction instead of creating one'` — pass a callback that records its argument in a local and returns `true`, enter `75` into `find.widgetWithText(TextField, 'R\$ Valor')`, `pump`, tap `find.text('Enviar')`, `pumpAndSettle`, expect the recorded transaction's `id` to equal `42` and its `amountCents` to equal `7500`, and `find.byType(TransactionDialog)` to find nothing.
   - `'should stay open when onSubmitEdit returns false'` — pass a callback returning `false`, tap `find.text('Enviar')`, `pumpAndSettle`, expect `find.byType(TransactionDialog)` to still find one widget.
9. Run the §5 write-only formatter on this block's paths only:
   ```
   dart format lib/presentation/ui/widgets/transaction_dialog.dart test/presentation/ui/widgets/transaction_dialog_test.dart
   ```

### Do not
- Do not disable, hide or lock the `Repete` switch. It stays live for every transaction; the scope dialog is what refuses the impossible combination, and BLOCK 12 tells it which option to disable.
- Do not add a heading, a different button label or an "editing" banner to the dialog. The submit button keeps `l10n.formSubmitButton`; §9 forbids a second key for text that already exists.
- Do not write back to the two controllers when the ViewModel notifies. They are seeded once in `initState` and the user owns them afterwards; writing back would move the caret while typing.
- Do not add a date field. §3 puts `humanDate` editing out of scope.
- Do not touch `lib/presentation/ui/screens/main_screen.dart` — that is BLOCK 12.

### Verify
Run from the repository root, in this order:
```
flutter test test/presentation/ui/widgets/transaction_dialog_test.dart
flutter test test/presentation/viewmodel/transaction_form_viewmodel_test.dart
flutter analyze
```
Expected: the first command exits 0 and reports `+6` passing tests — 3 before this block plus the 3
added by step 8; the second exits 0 and reports `+35`; the third exits 0 and prints
`No issues found!`.

### If verification fails
1. Read the failing output in full.
2. Fix only files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 9's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/presentation/ui/widgets/transaction_dialog.dart test/presentation/ui/widgets/transaction_dialog_test.dart PLAN.md
   git commit -m "Pre-fill the transaction dialog when the form is editing"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.
