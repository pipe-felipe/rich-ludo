## BLOCK 6 — Extract `MonthSelector` and delete the chart button

**Depends on:** BLOCK 5 committed
**Touches:** `lib/presentation/ui/widgets/month_selector.dart` (NEW), `lib/presentation/ui/widgets/main_top_bar.dart` (MODIFY)

### Goal
`MonthSelector` is a shared public widget in its own file, `MainTopBar` uses it, and
`main_top_bar.dart` contains no chart button and no import of `chart_screen.dart`.

### Context to read first
1. `lib/presentation/ui/widgets/main_top_bar.dart` — the whole file (272 lines). Lines 65-109 hold `_MonthSelector`, which moves out unchanged; lines 257-272 hold `_ChartNavigatorButton`, which is deleted; line 2 holds the `chart_screen.dart` import, which is deleted.
2. `lib/presentation/ui/widgets/empty_state.dart` — the shape of a small standalone public widget file in this folder: `import 'package:flutter/material.dart';`, a blank line, relative imports, then one public `StatelessWidget`.
3. `test/presentation/ui/widgets/main_top_bar_test.dart:14-33` — the existing test builds `MainTopBar` with all 9 named parameters; those parameters must not change in this block.
4. §7 rule 6 — `MainTopBar` must stay a pure renderer: no navigation, no database access, no `DateTime.now()`.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. Create `lib/presentation/ui/widgets/month_selector.dart` containing:
   ```dart
   import 'package:flutter/material.dart';

   /// Month header with previous/next arrows and a tap target that jumps back
   /// to the calendar's current month. Shared by [MainTopBar] and [ChartScreen].
   class MonthSelector extends StatelessWidget {
   ```
   followed by the body of `_MonthSelector` copied verbatim from
   `lib/presentation/ui/widgets/main_top_bar.dart:66-108`, with the constructor renamed from
   `const _MonthSelector({` to `const MonthSelector({` and `super.key,` added as its first
   parameter, and the closing brace of the class.
2. In `lib/presentation/ui/widgets/main_top_bar.dart`, delete line 2:
   `import 'package:rich_ludo/presentation/ui/screens/chart_screen.dart';`
3. In the same file, insert after the line `import '../theme/app_theme.dart';`:
   ```dart
   import 'month_selector.dart';
   ```
4. In the same file, inside `MainTopBar.build`, replace `_MonthSelector(` with `MonthSelector(`.
5. In the same file, delete the whole `class _MonthSelector extends StatelessWidget { ... }`
   declaration (originally lines 65-109) including the blank line that follows it.
6. In the same file, delete the line `          _ChartNavigatorButton(),` from the `Column`
   children of `MainTopBar.build`.
7. In the same file, delete the whole
   `class _ChartNavigatorButton extends StatelessWidget { ... }` declaration (originally lines
   257-272) and the blank line before it, so the file ends with the closing brace of
   `_IncomeExpenseColorBar`.
8. Format the two files:
   ```
   dart format lib/presentation/ui/widgets/month_selector.dart lib/presentation/ui/widgets/main_top_bar.dart
   ```

### Do not
- Do not rename `_IncomeExpenseColorBar`, `_SummaryRow`, or `_SummaryItem`, and do not move them out of `main_top_bar.dart`. Only `_MonthSelector` is extracted.
- Do not change `MonthSelector`'s visual code while moving it: same `Row`, same `IconButton`s, same `Icons.keyboard_arrow_left` / `Icons.keyboard_arrow_right`, same `TextButton`, same `Theme.of(context).colorScheme.tertiary`, same `titleMedium` with `FontWeight.w600`.
- Do not change `MainTopBar`'s constructor parameters; `test/presentation/ui/widgets/main_top_bar_test.dart` passes all 9 by name.
- Do not delete `lib/presentation/ui/screens/chart_screen.dart` — BLOCK 8 rewrites it.
- Do not add navigation, a route, or a `Navigator` call anywhere in this block.
- Do not run `dart format` on any path other than the two named in step 8.

### Verify
Run from the repository root, in this order:
```
grep -n "_ChartNavigatorButton\|_MonthSelector\|chart_screen" lib/presentation/ui/widgets/main_top_bar.dart
grep -c "_IncomeExpenseColorBar" lib/presentation/ui/widgets/main_top_bar.dart
flutter test test/presentation/ui/widgets/main_top_bar_test.dart
flutter analyze
```
Expected: the first command prints nothing and exits 1; the second prints `3` (the usage in
`MainTopBar.build`, the class declaration and the constructor); the third exits 0
and prints `+6: All tests passed!`; `flutter analyze` exits 0 printing `No issues found!`.

### If verification fails
1. Read the failing output in full.
2. Fix only files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 6's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/presentation/ui/widgets/month_selector.dart lib/presentation/ui/widgets/main_top_bar.dart PLAN.md
   git commit -m "Extract MonthSelector and drop the chart navigation button"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.
