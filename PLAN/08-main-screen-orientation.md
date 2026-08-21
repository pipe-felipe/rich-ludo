## BLOCK 8 — Choose the content by orientation in `MainScreen`

**Depends on:** BLOCK 7 committed
**Touches:** `lib/presentation/ui/screens/main_screen.dart` (MODIFY)

### Goal
`MainScreen` shows `MainTopBar` plus the transaction list in portrait and `ChartScreen` in
landscape, with the month-swipe gesture working in both and no bottom bar in landscape.

### Context to read first
1. `lib/presentation/ui/screens/main_screen.dart:22-82` — `MainScreen.build`: `Consumer` → `Scaffold` → `SafeArea` → `Stack` → `GestureDetector`(`onHorizontalDragEnd`) → `Column[MainTopBar, Expanded(_TransactionContent)]`, plus the `Positioned` bottom bar.
2. `lib/presentation/ui/screens/main_screen.dart:84-101` — `_formatMonthYear(context, month, year)`, already used for `MainTopBar`.
3. `lib/presentation/ui/screens/main_screen.dart:194-222` — `_TransactionContent`, the load-state pattern the new widget mirrors: `ListenableBuilder(listenable: viewModel.load)` → `running` spinner → `error` `ErrorState(onRetry: viewModel.load.execute)` → empty `EmptyState` → content.
4. `lib/presentation/ui/screens/chart_screen.dart` — the 7 named parameters `ChartScreen` requires.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. In `lib/presentation/ui/screens/main_screen.dart`, insert the sibling import
   ```dart
   import 'chart_screen.dart';
   ```
   immediately after the line `import '../../viewmodel/transaction_form_viewmodel.dart';`.
2. In the same file, as the first statement inside the `Consumer<MainScreenViewModel>` builder
   (before `return Scaffold(`), insert:
   ```dart
   final isPortrait =
       MediaQuery.orientationOf(context) == Orientation.portrait;
   final currentMonthYear = _formatMonthYear(
     context,
     viewModel.currentMonth,
     viewModel.currentYear,
   );
   ```
3. In the same file, replace the `Column`'s `children` list inside the `GestureDetector` with:
   ```dart
   children: [
     if (isPortrait)
       MainTopBar(
         totalIncomeText: viewModel.totalIncomeText,
         totalExpenseText: viewModel.totalExpenseText,
         totalSavingText: viewModel.totalSavingText,
         totalIncomeCents: viewModel.totalIncomeCents,
         totalExpenseCents: viewModel.totalExpenseCents,
         currentMonthYear: currentMonthYear,
         onPreviousMonth: viewModel.goToPreviousMonth,
         onNextMonth: viewModel.goToNextMonth,
         onCurrentMonthClick: viewModel.goToCurrentMonth,
       ),
     Expanded(
       child: isPortrait
           ? _TransactionContent(viewModel: viewModel)
           : _ChartContent(
               viewModel: viewModel,
               currentMonthYear: currentMonthYear,
             ),
     ),
   ],
   ```
   The `currentMonthYear:` argument now uses the local variable, so the inline
   `_formatMonthYear(...)` call that was there is gone.
4. In the same file, wrap the `Positioned` bottom bar in the `Stack`'s children with
   `if (isPortrait)`, so the `Stack` children read
   `GestureDetector(...)` then `if (isPortrait) Positioned(...)`. Landscape hides
   `MainBottomBar`: the dock is 70 px tall plus padding and would cover the chart on a short
   landscape viewport, and add / backup / export are portrait actions.
5. In the same file, immediately after the closing brace of the `_TransactionContent` class,
   append:
   ```dart
   class _ChartContent extends StatelessWidget {
     final MainScreenViewModel viewModel;
     final String currentMonthYear;

     const _ChartContent({
       required this.viewModel,
       required this.currentMonthYear,
     });

     @override
     Widget build(BuildContext context) {
       return ListenableBuilder(
         listenable: viewModel.load,
         builder: (context, _) {
           if (viewModel.load.running) {
             return const Center(child: CircularProgressIndicator());
           }

           if (viewModel.load.error) {
             return ErrorState(onRetry: viewModel.load.execute);
           }

           if (viewModel.expenseByCategory.isEmpty) {
             return const EmptyState();
           }

           return ChartScreen(
             categoryTotals: viewModel.expenseByCategory,
             totalExpenseCents: viewModel.totalExpenseCents,
             totalExpenseText: viewModel.totalExpenseText,
             currentMonthYear: currentMonthYear,
             onPreviousMonth: viewModel.goToPreviousMonth,
             onNextMonth: viewModel.goToNextMonth,
             onCurrentMonthClick: viewModel.goToCurrentMonth,
           );
         },
       );
     }
   }
   ```
6. Format the file:
   ```
   dart format lib/presentation/ui/screens/main_screen.dart
   ```

### Do not
- Do not move, wrap, or duplicate the `GestureDetector`; it must stay outside the orientation branch so `onHorizontalDragEnd` changes the month in landscape too.
- Do not add `SystemChrome.setPreferredOrientations` anywhere (§9).
- Do not use `OrientationBuilder`; `MediaQuery.orientationOf(context)` is the decided API and already rebuilds on rotation.
- Do not add a route, a `Navigator.push`, a `PageView`, or a tab bar.
- Do not change `_TransactionContent`, `_showTransactionDialog`, `_exportDatabase`, `_importDatabase`, or `_formatMonthYear`.
- Do not show `MainTopBar` in landscape; `ChartScreen` renders its own `MonthSelector` header.
- Do not run `dart format` on any path other than the one named in step 6.

### Verify
Run from the repository root, in this order:
```
grep -n "MediaQuery.orientationOf\|if (isPortrait)" lib/presentation/ui/screens/main_screen.dart
flutter test
flutter analyze
flutter build apk --debug
```
Expected: the first command prints exactly 3 lines — one `MediaQuery.orientationOf` assignment,
one `if (isPortrait)` before `MainTopBar`, one `if (isPortrait)` before `Positioned`;
`flutter test` exits 0 and prints `All tests passed!` with a count no lower than the previous
block's; `flutter analyze` exits 0 printing `No issues found!`; `flutter build apk --debug`
exits 0 printing `✓ Built build/app/outputs/flutter-apk/app-debug.apk` after roughly 60 seconds.

### If verification fails
1. Read the failing output in full.
2. Fix only `lib/presentation/ui/screens/main_screen.dart`.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 8's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/presentation/ui/screens/main_screen.dart PLAN.md
   git commit -m "Show the expenses chart when the device is in landscape"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.
