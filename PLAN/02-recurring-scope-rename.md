## BLOCK 2 — Rename the recurring delete mode and dialog to a neutral scope

**Depends on:** BLOCK 1 committed
**Touches:** `lib/domain/model/recurring_scope.dart` (NEW), `lib/domain/usecase/delete_recurring_transaction_usecase.dart` (MODIFY), `lib/presentation/ui/widgets/recurring_scope_dialog.dart` (NEW, replaces `lib/presentation/ui/widgets/recurring_delete_dialog.dart`, which is deleted), `lib/presentation/viewmodel/main_screen_viewmodel.dart` (MODIFY), `lib/presentation/ui/screens/main_screen.dart` (MODIFY), `test/domain/usecase/delete_recurring_transaction_usecase_test.dart` (MODIFY)

6 files: mechanical rename of one exported enum and one exported widget; every call site is listed
above and `grep` in **Verify** proves none was missed. The edit flow in BLOCK 7 and BLOCK 12 reuses
both symbols, so §9 forbids declaring a second copy.

### Goal
`RecurringScope` and `RecurringScopeDialog` are the only scope enum and the only scope dialog in
the repository, and the delete flow still behaves exactly as before.

### Context to read first
1. `lib/domain/usecase/delete_recurring_transaction_usecase.dart:1-37` — the `RecurringDeleteMode` declaration and the `switch` that consumes it.
2. `lib/presentation/ui/widgets/recurring_delete_dialog.dart` — the whole file (145 lines). Its `show` method, its four `_DialogPillOption` entries and the private `_DialogPillOption` widget move unchanged except for the renames and the new `title` parameter.
3. `lib/presentation/ui/screens/main_screen.dart:247-259` — `_handleDelete`, the only caller of the dialog.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. Create `lib/domain/model/recurring_scope.dart` with exactly this content:
   ```dart
   /// The span of months an operation on a recurring transaction applies to.
   /// Shared by the delete flow and the edit flow.
   enum RecurringScope {
     thisMonth,
     allMonths,
     thisAndPreviousMonths,
     thisAndFutureMonths,
   }
   ```
2. In `lib/domain/usecase/delete_recurring_transaction_usecase.dart`, delete the whole `enum RecurringDeleteMode { ... }` declaration on lines 6 to 11, and add `import '../model/recurring_scope.dart';` to the import block, keeping the existing alphabetical order of the `../model/` imports.
3. In the same file, replace every remaining `RecurringDeleteMode` with `RecurringScope`. There are 5 of them: the `mode` parameter type and the four `case` labels.
4. Rename the dialog file:
   ```
   git mv lib/presentation/ui/widgets/recurring_delete_dialog.dart lib/presentation/ui/widgets/recurring_scope_dialog.dart
   ```
5. In `lib/presentation/ui/widgets/recurring_scope_dialog.dart`, replace the import of the use case with `import '../../../domain/model/recurring_scope.dart';`, rename the class `RecurringDeleteDialog` to `RecurringScopeDialog` in its declaration and its constructor, replace every `RecurringDeleteMode` with `RecurringScope`, and replace the `show` method and the title `Text` so the caller supplies the heading. `show` becomes:
   ```dart
   static Future<RecurringScope?> show(
     BuildContext context, {
     required String title,
   }) {
     return showDialog<RecurringScope>(
       context: context,
       builder: (_) => RecurringScopeDialog(title: title),
     );
   }
   ```
   The class gains `final String title;` and the constructor becomes
   `const RecurringScopeDialog({super.key, required this.title});`, and the first child of the
   `Column` renders `title` where it used `l10n.recurringDeleteTitle`.
6. In the same file, keep the `final l10n = AppLocalizations.of(context)!;` line and the `AppLocalizations` import: the four option labels (`recurringDeleteThisMonth`, `recurringDeleteBackwards`, `recurringDeleteForwards`, `recurringDeleteAll`) and the close button (`formCloseButtonDescription`) still read from `l10n`. Only the title stops reading from it.
7. In `lib/presentation/viewmodel/main_screen_viewmodel.dart`, add `import '../../domain/model/recurring_scope.dart';` to the import block after the existing `import '../../domain/model/recurring_exclusion.dart';`, and change the `mode` parameter of `deleteRecurringItem` on line 354 from `RecurringDeleteMode` to `RecurringScope`.
8. In `lib/presentation/ui/screens/main_screen.dart`, change the import `import '../widgets/recurring_delete_dialog.dart';` to `import '../widgets/recurring_scope_dialog.dart';`, and inside `_handleDelete` replace `await RecurringDeleteDialog.show(context)` with:
   ```dart
   await RecurringScopeDialog.show(
     context,
     title: AppLocalizations.of(context)!.recurringDeleteTitle,
   );
   ```
9. In `test/domain/usecase/delete_recurring_transaction_usecase_test.dart`, add `import 'package:rich_ludo/domain/model/recurring_scope.dart';` after the existing `transaction_type.dart` import, and replace all 9 occurrences of `RecurringDeleteMode` with `RecurringScope`.
10. Run the §5 write-only formatter on this block's paths only:
    ```
    dart format lib/domain/model/recurring_scope.dart lib/domain/usecase/delete_recurring_transaction_usecase.dart lib/presentation/ui/widgets/recurring_scope_dialog.dart lib/presentation/viewmodel/main_screen_viewmodel.dart lib/presentation/ui/screens/main_screen.dart test/domain/usecase/delete_recurring_transaction_usecase_test.dart
    ```

### Do not
- Do not change any behaviour: no new option, no reordered options, no changed colors, no changed labels. This block is a rename plus one new `title` parameter.
- Do not add the disabled-option parameter here — that is BLOCK 5.
- Do not keep a `typedef RecurringDeleteMode = RecurringScope;` compatibility alias. §9 allows exactly one name for the enum.
- Do not touch `lib/domain/usecase/delete_recurring_transaction_usecase.dart` beyond the enum removal, the import and the 5 renames; its month arithmetic is BLOCK 3.

### Verify
Run from the repository root, in this order:
```
grep -rn "RecurringDeleteMode\|RecurringDeleteDialog\|recurring_delete_dialog" lib test integration_test
flutter analyze
flutter test
```
Expected: the first command prints nothing and exits 1, which is `grep` reporting no match; the
second exits 0 and prints `No issues found!`; the third exits 0 and reports 298 passing tests,
0 failing — 290 from §6 Baseline plus the 8 added by BLOCK 1.

### If verification fails
1. Read the failing output in full.
2. Fix only files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 2's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/domain/model/recurring_scope.dart lib/domain/usecase/delete_recurring_transaction_usecase.dart lib/presentation/ui/widgets/recurring_scope_dialog.dart lib/presentation/ui/widgets/recurring_delete_dialog.dart lib/presentation/viewmodel/main_screen_viewmodel.dart lib/presentation/ui/screens/main_screen.dart test/domain/usecase/delete_recurring_transaction_usecase_test.dart PLAN.md
   git commit -m "Rename the recurring delete mode and dialog to a neutral scope"
   ```
   `git mv` in step 4 already staged the deletion of `recurring_delete_dialog.dart`; naming it in
   `git add` is harmless and keeps the rename in one commit.

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.
