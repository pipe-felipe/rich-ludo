## BLOCK 8 — Rewrite `ChartScreen` as the landscape content

**Depends on:** BLOCK 7 committed
**Touches:** `lib/presentation/ui/screens/chart_screen.dart` (MODIFY), `test/presentation/ui/screens/chart_screen_test.dart` (NEW)

### Goal
`ChartScreen` renders, from plain parameters, a month header with navigation, the pie chart on
the left, the legend on the right, and the month's total expenses at the bottom.

### Context to read first
1. `lib/presentation/ui/screens/chart_screen.dart` — the whole current file (10 lines); it is replaced.
2. `lib/presentation/ui/widgets/main_top_bar.dart:1-63` — the pure-renderer contract to mirror: `final` fields for every value and every callback, a `const` constructor, no `Provider`, no `Consumer`, no `ListenableBuilder`, no `Navigator`.
3. `lib/presentation/ui/widgets/month_selector.dart` — `MonthSelector`, which supplies the header; it takes `currentMonthYear`, `onPreviousMonth`, `onNextMonth`, `onCurrentMonthClick`.
4. `lib/presentation/ui/widgets/chart/pie_chart.dart` — `PieChart` and `CategoryLegend`, both taking `categoryTotals` and `totalExpenseCents`.
5. `test/presentation/ui/widgets/main_top_bar_test.dart:9-33` — the widget-test harness to mirror.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. Replace the entire contents of `lib/presentation/ui/screens/chart_screen.dart` with a file
   that has, in this order:
   - the imports `package:flutter/material.dart`, then the relative imports `../../../domain/model/category_total.dart`, `../../../l10n/app_localizations.dart`, `../widgets/chart/pie_chart.dart`, `../widgets/month_selector.dart`;
   - a single public widget
     ```dart
     /// Landscape content of [MainScreen]: the selected month's expenses split
     /// by category. A pure renderer — every value and callback is a parameter.
     class ChartScreen extends StatelessWidget {
       final List<CategoryTotal> categoryTotals;
       final int totalExpenseCents;
       final String totalExpenseText;
       final String currentMonthYear;
       final VoidCallback onPreviousMonth;
       final VoidCallback onNextMonth;
       final VoidCallback onCurrentMonthClick;

       const ChartScreen({
         super.key,
         required this.categoryTotals,
         required this.totalExpenseCents,
         required this.totalExpenseText,
         required this.currentMonthYear,
         required this.onPreviousMonth,
         required this.onNextMonth,
         required this.onCurrentMonthClick,
       });
     ```
   - a `build` that reads `final l10n = AppLocalizations.of(context)!;` and returns
     ```dart
     Column(
       children: [
         MonthSelector(
           currentMonthYear: currentMonthYear,
           onPreviousMonth: onPreviousMonth,
           onNextMonth: onNextMonth,
           onCurrentMonthClick: onCurrentMonthClick,
         ),
         Expanded(
           child: Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16),
             child: Row(
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 Expanded(
                   child: PieChart(
                     categoryTotals: categoryTotals,
                     totalExpenseCents: totalExpenseCents,
                   ),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         l10n.chartTitle,
                         style: Theme.of(context).textTheme.titleSmall
                             ?.copyWith(fontWeight: FontWeight.w600),
                       ),
                       const SizedBox(height: 8),
                       Expanded(
                         child: CategoryLegend(
                           categoryTotals: categoryTotals,
                           totalExpenseCents: totalExpenseCents,
                         ),
                       ),
                     ],
                   ),
                 ),
               ],
             ),
           ),
         ),
         Padding(
           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text(
                 l10n.chartTotalExpense,
                 style: Theme.of(context).textTheme.labelMedium,
               ),
               Text(
                 totalExpenseText,
                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
                   color: Theme.of(context).colorScheme.error,
                   fontWeight: FontWeight.w600,
                 ),
               ),
             ],
           ),
         ),
       ],
     )
     ```
2. Create `test/presentation/ui/screens/chart_screen_test.dart` mirroring the harness of
   `test/presentation/ui/widgets/main_top_bar_test.dart` (`MaterialApp` with
   `AppTheme.lightTheme()`, the `AppLocalizations` delegates and locales, `locale: const
   Locale('pt')`, a `Scaffold` body), with a local `pumpChartScreen` helper that accepts the
   callbacks and defaults them to no-ops, and exactly 4 tests in
   `group('ChartScreen', ...)`:
   - `'should show the month and the total expenses'` — pump with `currentMonthYear: 'Julho 2026'`, `totalExpenseText: 'R\$ 100.00'`, one `CategoryTotal(category: 'food', amountCents: 10000)` and `totalExpenseCents: 10000`; expect `find.text('Julho 2026')`, `find.text('R\$ 100.00')` and `find.text('Total de despesas')` each find one widget.
   - `'should show one legend entry per category'` — pump with 2 `CategoryTotal`s (`'food'` 6000, `'transport'` 4000) and `totalExpenseCents: 10000`; expect `find.text('Comida')` and `find.text('Transporte')` each find one widget.
   - `'should call onNextMonth when the right arrow is tapped'` — pump with an `onNextMonth` that flips a local `bool`, `tester.tap(find.byIcon(Icons.keyboard_arrow_right))`, `await tester.pump()`, expect the bool is `true`.
   - `'should call onPreviousMonth when the left arrow is tapped'` — same shape with `Icons.keyboard_arrow_left`.
   Wrap every pump with `tester.view.physicalSize = const Size(1600, 900);`,
   `tester.view.devicePixelRatio = 1.0;` and `addTearDown(tester.view.resetPhysicalSize);` so the
   landscape layout has room, following the same `tester.view` pattern the Flutter test API uses.
3. Format the two files:
   ```
   dart format lib/presentation/ui/screens/chart_screen.dart test/presentation/ui/screens/chart_screen_test.dart
   ```

### Do not
- Do not add a `Scaffold`, `AppBar`, or `SafeArea` to `ChartScreen`; it renders inside the `Scaffold` and `SafeArea` that `MainScreen` already provides.
- Do not read `MainScreenViewModel` here — no `Provider`, `Consumer`, `context.read`, or `context.watch`. BLOCK 9 passes the values in.
- Do not build the month name from `DateTime`; `currentMonthYear` arrives already formatted.
- Do not call `formatMoney` here; `totalExpenseText` arrives already formatted by the ViewModel.
- Do not copy the body of `MonthSelector` into this file (§9).
- Do not add a spinner, an error state, or an empty state here — BLOCK 9 wires those around it.
- Do not run `dart format` on any path other than the two named in step 3.

### Verify
Run from the repository root, in this order:
```
flutter test test/presentation/ui/screens/chart_screen_test.dart
grep -c "Provider\|Navigator\|Scaffold\|DateTime" lib/presentation/ui/screens/chart_screen.dart
flutter analyze
```
Expected: the first command exits 0 and prints `+4: All tests passed!`; the second prints `0`;
`flutter analyze` exits 0 printing `No issues found!`.

### If verification fails
1. Read the failing output in full.
2. Fix only files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 8's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/presentation/ui/screens/chart_screen.dart test/presentation/ui/screens/chart_screen_test.dart PLAN.md
   git commit -m "Render the landscape expenses chart screen"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.
