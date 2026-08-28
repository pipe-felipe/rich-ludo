## BLOCK 12 — Add the edit e2e test

**Depends on:** BLOCK 11 committed
**Touches:** `integration_test/edit_transaction_test.dart` (NEW)

### Goal
`flutter test integration_test/edit_transaction_test.dart -d emulator-5554` drives the running app
through the four edit paths and passes.

### Context to read first
1. `integration_test/custom_categories_test.dart` — the whole file (222 lines): the mold this test follows. Copy its structure — `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`, a `TransactionLocalService` used to reset and seed, a `startApp` helper, an `openTransactionDialog` helper tapping `find.image(const AssetImage('assets/icons/add-item.png'))`, and the doc comment naming the run command.
2. `integration_test/chart_orientation_test.dart:26-74` — the `seed()` helper: `service.deleteAll()` followed by `service.insertAll([...])` with explicit `targetMonth` and `targetYear`, and `flingFrom` for changing months.
3. `lib/l10n/app_pt.arb` — the exact Portuguese strings the test taps and asserts: `Enviar`, `Repete`, `R$ Valor`, `Notas`, `Editar recorrente`, `Apenas este mês`, `Este mês e anteriores`, `Todos os meses`.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. Create `integration_test/edit_transaction_test.dart` with a doc comment in English describing the coverage and the run command `flutter test integration_test/edit_transaction_test.dart -d <device>`, then these helpers inside `main()`:
   - `final service = TransactionLocalService();` and `final now = DateTime.now();`
   - `Future<void> seedOneOff()` — `await service.deleteAll();` then `service.insertAll` with one `Transaction(amountCents: 5000, type: TransactionType.expense, category: 'food', description: 'Almoço', humanDate: '2026-08-04', targetMonth: now.month, targetYear: now.year)`.
   - `Future<void> seedRecurring()` — `await service.deleteAll();` then `service.insertAll` with one `Transaction(amountCents: 10000, type: TransactionType.expense, category: 'recurring', description: 'Aluguel', humanDate: '2026-08-01', isRecurring: true, targetMonth: now.month, targetYear: now.year)`.
   - `Future<void> startApp(WidgetTester tester)` — runs `app.main()` and `await tester.pumpAndSettle()`. Each test calls its own seed helper before `startApp`.
   - `Future<void> openEditDialog(WidgetTester tester)` — taps `find.byIcon(Icons.edit)` and `pumpAndSettle`.
   - `Future<void> enterAmount(WidgetTester tester, String amount)` — `tester.enterText(find.widgetWithText(TextField, 'R\$ Valor'), amount)` followed by `await tester.pump()`.
   - `Future<void> submit(WidgetTester tester)` — taps `find.text('Enviar')` and `pumpAndSettle`.
   - `Future<void> goToNextMonth(WidgetTester tester)` — `tester.flingFrom(tester.getCenter(find.byType(app.RichLudoApp)), const Offset(-400, 0), 1000)` followed by `pumpAndSettle`.
2. In the same file, write one `group('Edit transaction', ...)` holding exactly 4 tests:
   - `'editing a one-off transaction writes the new amount and notes'` — seed with `seedOneOff`, start, open the edit dialog, expect `find.widgetWithText(TextField, '50.00')` to find one widget, enter `75`, enter `Jantar` into `find.widgetWithText(TextField, 'Notas')`, submit, then expect `find.text('-R\$75.00')` and `find.text('Jantar')` to each find one widget and `find.text('-R\$50.00')` to find nothing.
   - `'editing a recurring transaction for all months changes every month'` — seed with `seedRecurring`, start, open the edit dialog, enter `120`, submit, tap `find.text('Todos os meses')`, `pumpAndSettle`, expect `find.text('-R\$120.00')` to find one widget; then `goToNextMonth` and expect `find.text('-R\$120.00')` to find one widget there too.
   - `'editing a recurring transaction for this month leaves the next month alone'` — seed with `seedRecurring`, start, open the edit dialog, enter `250`, submit, tap `find.text('Apenas este mês')`, `pumpAndSettle`, expect `find.text('-R\$250.00')` to find one widget and `find.text('-R\$100.00')` to find nothing; then `goToNextMonth` and expect `find.text('-R\$100.00')` to find one widget and `find.text('-R\$250.00')` to find nothing.
   - `'turning Repete off leaves this month and previous unreachable'` — seed with `seedRecurring`, start, open the edit dialog, tap `find.byType(Switch)`, `pump`, submit, expect `find.text('Editar recorrente')` to find one widget, tap `find.text('Este mês e anteriores')`, `pumpAndSettle`, expect `find.text('Editar recorrente')` to still find one widget, then tap `find.text('Todos os meses')`, `pumpAndSettle`, and expect `find.text('Editar recorrente')` to find nothing.
3. Run the §5 write-only formatter on this block's path only:
   ```
   dart format integration_test/edit_transaction_test.dart
   ```

### Do not
- Do not change any file under `lib/`. If a test fails because the app is wrong, that is a stop condition under §11 R12, not a licence to edit BLOCK 11's files.
- Do not weaken an assertion to make a test pass, and do not delete one of the four tests (§11 R6).
- Do not touch `integration_test/custom_categories_test.dart` or `integration_test/chart_orientation_test.dart`.
- Do not add a fifth test for the scope dialog's disabled pill at the widget level; `test/presentation/ui/widgets/recurring_scope_dialog_test.dart` from BLOCK 5 already covers it.

### Verify
Run from the repository root, in this order:
```
flutter test integration_test/edit_transaction_test.dart -d emulator-5554
flutter test integration_test/custom_categories_test.dart -d emulator-5554
flutter test integration_test/chart_orientation_test.dart -d emulator-5554
```
Expected: the first command exits 0 and reports `+4` passing tests; the second exits 0 and reports
`+4`; the third exits 0 and reports `+3`. The second and third are §6 Baseline numbers and prove the
edit button did not break the existing flows.

### If verification fails
1. Read the failing output in full.
2. Fix only files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 12's row in §12 Status to `DONE`.
2. Run:
   ```
   git add integration_test/edit_transaction_test.dart PLAN.md
   git commit -m "Add the transaction edit e2e test"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.
