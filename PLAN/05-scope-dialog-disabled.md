## BLOCK 5 — Let the scope dialog disable one option

**Depends on:** BLOCK 4 committed
**Touches:** `lib/presentation/ui/widgets/recurring_scope_dialog.dart` (MODIFY), `test/presentation/ui/widgets/recurring_scope_dialog_test.dart` (NEW)

### Goal
`RecurringScopeDialog.show(context, title: ..., disabledScopes: {RecurringScope.thisAndPreviousMonths})`
renders that one option greyed out and non-tappable, and tapping it neither closes the dialog nor
returns a value.

### Context to read first
1. `lib/presentation/ui/widgets/recurring_scope_dialog.dart` — the whole file as BLOCK 2 left it: the `show` method, the four `_DialogPillOption` entries, and the `_DialogPillOption` widget with its `isDestructive` flag.
2. `test/presentation/ui/widgets/category_manager_dialog_test.dart` — the widget test style to mirror: a `pumpWidget` helper wrapping the widget in `MaterialApp` with `AppTheme.lightTheme()`, `AppLocalizations.localizationsDelegates`, `locale: const Locale('pt')`.
3. `lib/l10n/app_pt.arb:37-41` — the exact Portuguese labels the test taps and asserts on.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. In `RecurringScopeDialog`, add a second field `final Set<RecurringScope> disabledScopes;` after `title`, give the constructor `this.disabledScopes = const {}` as an optional named parameter after `required this.title`, and extend `show` with the same optional parameter, forwarding it:
   ```dart
   static Future<RecurringScope?> show(
     BuildContext context, {
     required String title,
     Set<RecurringScope> disabledScopes = const {},
   }) {
     return showDialog<RecurringScope>(
       context: context,
       builder: (_) =>
           RecurringScopeDialog(title: title, disabledScopes: disabledScopes),
     );
   }
   ```
2. Give `_DialogPillOption` a fourth field `final bool isEnabled;` declared after `isDestructive`, with `this.isEnabled = true` in its constructor.
3. In `_DialogPillOption.build`, wrap the returned `Material` in an `Opacity` and disable the tap:
   - the `InkWell` receives `onTap: isEnabled ? onTap : null`;
   - the whole `Material` is returned as `Opacity(opacity: isEnabled ? 1.0 : 0.4, child: Material(...))`.
4. Pass the flag to each of the four options in `RecurringScopeDialog.build`, one per option, using the scope that option pops:
   ```dart
   isEnabled: !disabledScopes.contains(RecurringScope.thisMonth),
   ```
   and the same line with `thisAndPreviousMonths`, `thisAndFutureMonths` and `allMonths` on the other three.
5. Create `test/presentation/ui/widgets/recurring_scope_dialog_test.dart` with a `pumpDialog` helper that pushes the dialog through `RecurringScopeDialog.show` from a `Builder` button, records the returned `RecurringScope?`, and one `group('RecurringScopeDialog', ...)` holding exactly 4 test cases:
   - `'should return the tapped scope when nothing is disabled'` — pump with `disabledScopes: const <RecurringScope>{}`, tap `find.text('Apenas este mês')`, expect the recorded value to equal `RecurringScope.thisMonth` and the dialog to be gone.
   - `'should show the title it was given'` — pump with title `'Editar recorrente'`, expect `find.text('Editar recorrente')` to find one widget.
   - `'should not return a disabled scope when it is tapped'` — pump with `disabledScopes: const {RecurringScope.thisAndPreviousMonths}`, tap `find.text('Este mês e anteriores')`, `pumpAndSettle`, expect the recorded value to be `isNull` and `find.byType(RecurringScopeDialog)` to still find one widget.
   - `'should keep the other scopes tappable while one is disabled'` — pump with `disabledScopes: const {RecurringScope.thisAndPreviousMonths}`, tap `find.text('Todos os meses')`, expect the recorded value to equal `RecurringScope.allMonths`.
6. Run the §5 write-only formatter on this block's paths only:
   ```
   dart format lib/presentation/ui/widgets/recurring_scope_dialog.dart test/presentation/ui/widgets/recurring_scope_dialog_test.dart
   ```

### Do not
- Do not add a callback, a tooltip, an explanation text or a `SnackBar` for the disabled option. A greyed, inert pill is the whole behaviour.
- Do not change the delete flow's call in `lib/presentation/ui/screens/main_screen.dart`: it keeps the default empty set. Passing the set for the edit flow is BLOCK 12.
- Do not replace the `Set<RecurringScope>` parameter with a boolean flag; §9 point 2 keeps one dialog serving both flows and a boolean would name only the case this task happens to need.

### Verify
Run from the repository root, in this order:
```
flutter test test/presentation/ui/widgets/recurring_scope_dialog_test.dart
flutter test test/domain/usecase/delete_recurring_transaction_usecase_test.dart
flutter analyze
```
Expected: the first command exits 0 and reports `+4` passing tests; the second exits 0 and reports
`+9`; the third exits 0 and prints `No issues found!`.

### If verification fails
1. Read the failing output in full.
2. Fix only files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 5's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/presentation/ui/widgets/recurring_scope_dialog.dart test/presentation/ui/widgets/recurring_scope_dialog_test.dart PLAN.md
   git commit -m "Let the recurring scope dialog disable one option"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.
