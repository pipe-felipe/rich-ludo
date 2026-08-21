## BLOCK 7 — Make the pie chart data-driven and rewrite `ChartScreen`

**Depends on:** BLOCK 6 committed
**Touches:** `lib/presentation/ui/widgets/chart/pie_chart.dart` (MODIFY), `lib/presentation/ui/screens/chart_screen.dart` (MODIFY), `test/presentation/ui/widgets/chart/pie_chart_test.dart` (NEW), `test/presentation/ui/screens/chart_screen_test.dart` (NEW)

Merged by human decision after the original two-block split blocked: the original BLOCK 7 made
`categoryTotals`/`totalExpenseCents` required on `PieChart`, which broke the old WIP
`chart_screen.dart` caller, but that file was only rewritten in the original BLOCK 8 — an
unorderable cycle across two commits. Both halves now land in one block so `flutter analyze`
can pass.

### Goal
`PieChart` draws one slice per `CategoryTotal` it is given, `CategoryLegend` lists each category's
localized name, formatted amount and percentage, and `ChartScreen` renders from plain parameters
a month header with navigation, the pie chart on the left, the legend on the right, and the
month's total expenses at the bottom.

### Context to read first
1. `lib/presentation/ui/widgets/chart/pie_chart.dart` — the whole current file (134 lines). Keep its touch behaviour (`pieTouchData` callback setting `touchedIndex`, radius `50.0` → `60.0`, font `16.0` → `25.0`, `borderData` hidden, `sectionsSpace: 0`, `centerSpaceRadius: 40`) and its `_Indicator` swatch shape. Everything data-related is replaced.
2. `lib/presentation/ui/utils/money_formatter.dart` — `formatMoney(int amountCents)` returns the amount without a currency symbol; `lib/presentation/viewmodel/main_screen_viewmodel.dart:237-239` shows the `'R\$ ${formatMoney(cents)}'` convention used for on-screen money.
3. `lib/presentation/ui/utils/category_color.dart` and `lib/presentation/ui/utils/category_mapper.dart` — `getExpenseCategoryColor(String?)` and `getExpenseCategoryLabel(String?, AppLocalizations)`, the two resolvers this block calls.
4. `test/presentation/ui/widgets/main_top_bar_test.dart:14-46` — the widget-test style to mirror: a local `pump...` helper wrapping the widget in `MaterialApp` with `AppTheme.lightTheme()`, `AppLocalizations.localizationsDelegates`, `AppLocalizations.supportedLocales`, `locale: const Locale('pt')` and a `Scaffold` body, then `group(...)` with `testWidgets(...)`.
5. `lib/presentation/ui/screens/chart_screen.dart` — the whole current file (10 lines); it is replaced.
6. `lib/presentation/ui/widgets/main_top_bar.dart:1-63` — the pure-renderer contract to mirror: `final` fields for every value and every callback, a `const` constructor, no `Provider`, no `Consumer`, no `ListenableBuilder`, no `Navigator`.
7. `lib/presentation/ui/widgets/month_selector.dart` — `MonthSelector`, which supplies the header; it takes `currentMonthYear`, `onPreviousMonth`, `onNextMonth`, `onCurrentMonthClick`.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. Replace the entire contents of `lib/presentation/ui/widgets/chart/pie_chart.dart` with a file
   that has, in this order:
   - the imports `package:fl_chart/fl_chart.dart` as `fl`, `package:flutter/material.dart`, then the relative imports `../../../../domain/model/category_total.dart`, `../../../../l10n/app_localizations.dart`, `../../utils/category_color.dart`, `../../utils/category_mapper.dart`, `../../utils/money_formatter.dart`;
   - a top-level function
     ```dart
     /// Share of [amountCents] in [totalCents], rounded to a whole percent.
     int categoryPercentage(int amountCents, int totalCents) {
       if (totalCents <= 0) return 0;
       return ((amountCents * 100) / totalCents).round();
     }
     ```
   - `class PieChart extends StatefulWidget` with two `final` fields,
     `final List<CategoryTotal> categoryTotals;` and `final int totalExpenseCents;`, and the
     constructor `const PieChart({super.key, required this.categoryTotals, required this.totalExpenseCents});`
   - `class _PieChartState extends State<PieChart>` keeping `int touchedIndex = -1;` and the
     existing `pieTouchData` callback verbatim. Its `build` returns
     ```dart
     AspectRatio(
       aspectRatio: 1,
       child: fl.PieChart(
         fl.PieChartData(
           pieTouchData: fl.PieTouchData(touchCallback: ...),
           borderData: fl.FlBorderData(show: false),
           sectionsSpace: 0,
           centerSpaceRadius: 40,
           sections: _buildSections(),
         ),
       ),
     )
     ```
     and `_buildSections()` becomes
     ```dart
     List<fl.PieChartSectionData> _buildSections() {
       return List.generate(widget.categoryTotals.length, (i) {
         final total = widget.categoryTotals[i];
         final isTouched = i == touchedIndex;
         final fontSize = isTouched ? 25.0 : 16.0;
         final radius = isTouched ? 60.0 : 50.0;
         const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

         return fl.PieChartSectionData(
           color: getExpenseCategoryColor(total.category),
           value: total.amountCents.toDouble(),
           title:
               '${categoryPercentage(total.amountCents, widget.totalExpenseCents)}%',
           radius: radius,
           titleStyle: TextStyle(
             fontSize: fontSize,
             fontWeight: FontWeight.bold,
             color: Colors.white,
             shadows: shadows,
           ),
         );
       });
     }
     ```
   - `class CategoryLegend extends StatelessWidget` with the same two `final` fields and
     constructor shape as `PieChart`. Its `build` reads
     `final l10n = AppLocalizations.of(context)!;` and returns a `ListView.separated` with
     `itemCount: categoryTotals.length`, `separatorBuilder` returning
     `const SizedBox(height: 4)`, and `itemBuilder` returning
     ```dart
     _Indicator(
       color: getExpenseCategoryColor(total.category),
       label: getExpenseCategoryLabel(total.category, l10n),
       value: 'R\$ ${formatMoney(total.amountCents)}',
       percentage: categoryPercentage(total.amountCents, totalExpenseCents),
     )
     ```
   - `class _Indicator extends StatelessWidget` with `final Color color; final String label;
     final String value; final int percentage;`. Its `build` returns a `Row` with
     `crossAxisAlignment: CrossAxisAlignment.center` holding: the existing 16×16 `Container`
     swatch, `const SizedBox(width: 4)`, and an `Expanded` wrapping a `Column` with
     `crossAxisAlignment: CrossAxisAlignment.start` and two `Text` children — the first `label`
     with `Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)` and
     `overflow: TextOverflow.ellipsis`, the second `'$value  ($percentage%)'` with
     `Theme.of(context).textTheme.labelSmall`.
   The file ends with a trailing newline.
2. Create `test/presentation/ui/widgets/chart/pie_chart_test.dart` mirroring the harness style of
   `test/presentation/ui/widgets/main_top_bar_test.dart`, with a local
   `pumpChartWidget(WidgetTester tester, Widget child)` helper and exactly 6 tests:
   - `group('categoryPercentage', ...)`: `'should return the rounded share of the total'` — expect `categoryPercentage(2500, 10000)` equals `25`; `'should return zero when the total is zero'` — expect `categoryPercentage(500, 0)` equals `0`.
   - `group('CategoryLegend', ...)`: `'should render one row per category'` — pump `CategoryLegend` with 3 `CategoryTotal`s (`'food'` 5000, `'transport'` 3000, `null` 2000) and `totalExpenseCents: 10000`, then expect `find.byType(Row)` finds at least 3 and `find.textContaining('%')` finds exactly 3; `'should show the localized label, amount and percentage'` — with the same data, expect `find.text('R\$ 50.00  (50%)')` finds one widget and `find.text('Comida')` finds one widget (the harness locale is `pt`); `'should render nothing when there are no categories'` — pump with an empty list and `totalExpenseCents: 0`, expect `find.textContaining('%')` finds nothing.
   - `group('PieChart', ...)`: `'should build one section per category'` — pump `PieChart` with the same 3 `CategoryTotal`s, read the `fl.PieChart` widget with `tester.widget<fl.PieChart>(find.byType(fl.PieChart))` and expect `widget.data.sections.length` equals `3`.
3. Replace the entire contents of `lib/presentation/ui/screens/chart_screen.dart` with a file
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
4. Create `test/presentation/ui/screens/chart_screen_test.dart` mirroring the harness of
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
5. Format the four files:
   ```
   dart format lib/presentation/ui/widgets/chart/pie_chart.dart test/presentation/ui/widgets/chart/pie_chart_test.dart lib/presentation/ui/screens/chart_screen.dart test/presentation/ui/screens/chart_screen_test.dart
   ```

### Do not
- Do not keep `_sectionColors`, `_sectionLabels`, `_sectionValues`, or the strings `'First'`, `'Second'`, `'Third'`, `'Fourth'` anywhere in `pie_chart.dart`.
- Do not reintroduce the `const SizedBox(height: 18)` that sat inside a `Row`, and do not put the pie and the legend in one `Row` in `pie_chart.dart` — step 3 lays them out side by side in `ChartScreen`.
- Do not write `Color(0xFF...)` in this file (§9); every slice color comes from `getExpenseCategoryColor`.
- Do not compute the total from `categoryTotals` inside the widgets; it arrives as `totalExpenseCents`.
- Do not sort, filter, or re-group `categoryTotals`; the ViewModel already sorted them descending.
- Do not add a `Scaffold`, an `AppBar`, or padding around the chart inside `PieChart`/`CategoryLegend` — `ChartScreen` provides the layout.
- Do not add a `Scaffold`, `AppBar`, or `SafeArea` to `ChartScreen`; it renders inside the `Scaffold` and `SafeArea` that `MainScreen` already provides.
- Do not read `MainScreenViewModel` in `ChartScreen` — no `Provider`, `Consumer`, `context.read`, or `context.watch`. BLOCK 8 passes the values in.
- Do not build the month name from `DateTime`; `currentMonthYear` arrives already formatted.
- Do not call `formatMoney` in `ChartScreen`; `totalExpenseText` arrives already formatted by the ViewModel.
- Do not copy the body of `MonthSelector` into `chart_screen.dart` (§9).
- Do not add a spinner, an error state, or an empty state to `ChartScreen` — BLOCK 8 wires those around it.
- Do not run `dart format` on any path other than the four named in step 5.

### Verify
Run from the repository root, in this order:
```
flutter test test/presentation/ui/widgets/chart/pie_chart_test.dart
grep -c "First\|Second\|Third\|Fourth\|Color(0xFF" lib/presentation/ui/widgets/chart/pie_chart.dart
tail -c 1 lib/presentation/ui/widgets/chart/pie_chart.dart | xxd -p
flutter test test/presentation/ui/screens/chart_screen_test.dart
grep -c "Provider\|Navigator\|Scaffold\|DateTime" lib/presentation/ui/screens/chart_screen.dart
flutter analyze
```
Expected: the first command exits 0 and prints `+6: All tests passed!`; the second prints `0`;
the third prints `0a`; the fourth exits 0 and prints `+4: All tests passed!`; the fifth prints
`0`; `flutter analyze` exits 0 printing `No issues found!`.

### If verification fails
1. Read the failing output in full.
2. Fix only files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 7's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/presentation/ui/widgets/chart/pie_chart.dart lib/presentation/ui/screens/chart_screen.dart test/presentation/ui/widgets/chart/pie_chart_test.dart test/presentation/ui/screens/chart_screen_test.dart PLAN.md
   git commit -m "Draw the data-driven pie chart and the landscape chart screen"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.
