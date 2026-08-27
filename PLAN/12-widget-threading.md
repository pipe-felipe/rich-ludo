## BLOCK 12 — Pass the user-created categories to the list and the chart

**Depends on:** BLOCK 11 committed
**Touches:** `lib/presentation/ui/widgets/transaction_card.dart` (MODIFY), `lib/presentation/ui/widgets/transaction_list.dart` (MODIFY), `lib/presentation/ui/widgets/chart/pie_chart.dart` (MODIFY), `lib/presentation/ui/screens/chart_screen.dart` (MODIFY), `lib/presentation/ui/screens/main_screen.dart` (MODIFY), `test/presentation/ui/widgets/chart/pie_chart_test.dart` (MODIFY), `test/presentation/ui/screens/chart_screen_test.dart` (MODIFY)

7 files: one parameter threaded down two widget chains from the single place the real list
exists. `main_screen.dart` is that place; splitting this would leave `const []` placeholders in
the middle of both chains. Every path is listed, and the two chart widgets have mirrored tests.

### Goal
A transaction saved under a user-created category shows that category's stored icon in the list,
and its stored color and name in the landscape pie chart and its legend.

### Context to read first
1. `lib/presentation/ui/widgets/transaction_card.dart` — the whole file (128 lines); `_CategoryIcon` at line 59 is the only caller of `getCategoryIcon`.
2. `lib/presentation/ui/widgets/chart/pie_chart.dart` — the whole file (163 lines); `getExpenseCategoryColor` is called at line 71 and line 108, `getExpenseCategoryLabel` at line 109.
3. `lib/presentation/ui/screens/chart_screen.dart:8-9` — the doc comment stating `ChartScreen` is a pure renderer whose every value is a parameter; that is why the list is threaded rather than read from a `Provider` here.
4. `lib/presentation/ui/screens/main_screen.dart:24-93` and `:205-288` — the `Consumer<MainScreenViewModel>` builder, and `_TransactionContent` and `_ChartContent`, the two private widgets that receive the list.
5. `lib/presentation/viewmodel/category_viewmodel.dart` — `categories`, the full list across both transaction types, which is what the list and the chart resolve against.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. In `lib/presentation/ui/widgets/transaction_card.dart`, add this import immediately after `import 'package:flutter/material.dart';` and its blank line, before `import '../../../domain/model/transaction.dart';`:
   ```dart
   import '../../../domain/model/custom_category.dart';
   ```
2. In the same file, replace
   ```dart
     final Transaction item;
     final VoidCallback onDelete;

     const TransactionCard({
       super.key,
       required this.item,
       required this.onDelete,
     });
   ```
   with:
   ```dart
     final Transaction item;
     final List<CustomCategory> customCategories;
     final VoidCallback onDelete;

     const TransactionCard({
       super.key,
       required this.item,
       this.customCategories = const [],
       required this.onDelete,
     });
   ```
3. In the same file, in `TransactionCard.build`, replace
   ```dart
               _CategoryIcon(
                 category: item.category,
                 isIncome: _isIncome,
                 iconColor: iconColor,
               ),
   ```
   with:
   ```dart
               _CategoryIcon(
                 category: item.category,
                 customCategories: customCategories,
                 isIncome: _isIncome,
                 iconColor: iconColor,
               ),
   ```
4. In the same file, replace
   ```dart
     final String? category;
     final bool isIncome;
     final Color iconColor;

     const _CategoryIcon({
       required this.category,
       required this.isIncome,
       required this.iconColor,
     });
   ```
   with:
   ```dart
     final String? category;
     final List<CustomCategory> customCategories;
     final bool isIncome;
     final Color iconColor;

     const _CategoryIcon({
       required this.category,
       required this.customCategories,
       required this.isIncome,
       required this.iconColor,
     });
   ```
5. In the same file, in `_CategoryIcon.build`, replace
   ```dart
         child: Icon(
           getCategoryIcon(category, isIncome: isIncome),
   ```
   with:
   ```dart
         child: Icon(
           getCategoryIcon(
             category,
             isIncome: isIncome,
             customCategories: customCategories,
           ),
   ```
6. In `lib/presentation/ui/widgets/transaction_list.dart`, add this import immediately after `import 'package:flutter/material.dart';` and its blank line:
   ```dart
   import '../../../domain/model/custom_category.dart';
   ```
7. In the same file, replace
   ```dart
     final List<Transaction> items;
     final void Function(Transaction) onDelete;

     const TransactionList({
       super.key,
       required this.items,
       required this.onDelete,
     });
   ```
   with:
   ```dart
     final List<Transaction> items;
     final List<CustomCategory> customCategories;
     final void Function(Transaction) onDelete;

     const TransactionList({
       super.key,
       required this.items,
       this.customCategories = const [],
       required this.onDelete,
     });
   ```
8. In the same file, replace the line
   ```dart
           return TransactionCard(item: item, onDelete: () => onDelete(item));
   ```
   with:
   ```dart
           return TransactionCard(
             item: item,
             customCategories: customCategories,
             onDelete: () => onDelete(item),
           );
   ```
9. In `lib/presentation/ui/widgets/chart/pie_chart.dart`, add this import immediately after `import 'package:flutter/material.dart';` and its blank line, before `import '../../../../domain/model/category_total.dart';`:
   ```dart
   import '../../../../domain/model/custom_category.dart';
   ```
10. In the same file, replace
    ```dart
      final List<CategoryTotal> categoryTotals;
      final int totalExpenseCents;

      const PieChart({
        super.key,
        required this.categoryTotals,
        required this.totalExpenseCents,
      });
    ```
    with:
    ```dart
      final List<CategoryTotal> categoryTotals;
      final int totalExpenseCents;
      final List<CustomCategory> customCategories;

      const PieChart({
        super.key,
        required this.categoryTotals,
        required this.totalExpenseCents,
        this.customCategories = const [],
      });
    ```
11. In the same file, inside `_PieChartState._buildSections`, replace the line
    ```dart
          color: getExpenseCategoryColor(total.category),
    ```
    with:
    ```dart
          color: getExpenseCategoryColor(
            total.category,
            customCategories: widget.customCategories,
          ),
    ```
12. In the same file, replace
    ```dart
      final List<CategoryTotal> categoryTotals;
      final int totalExpenseCents;

      const CategoryLegend({
        super.key,
        required this.categoryTotals,
        required this.totalExpenseCents,
      });
    ```
    with:
    ```dart
      final List<CategoryTotal> categoryTotals;
      final int totalExpenseCents;
      final List<CustomCategory> customCategories;

      const CategoryLegend({
        super.key,
        required this.categoryTotals,
        required this.totalExpenseCents,
        this.customCategories = const [],
      });
    ```
13. In the same file, inside `CategoryLegend.build`, replace the two lines
    ```dart
            color: getExpenseCategoryColor(total.category),
            label: getExpenseCategoryLabel(total.category, l10n),
    ```
    with:
    ```dart
            color: getExpenseCategoryColor(
              total.category,
              customCategories: customCategories,
            ),
            label: getExpenseCategoryLabel(
              total.category,
              l10n,
              customCategories: customCategories,
            ),
    ```
14. In `lib/presentation/ui/screens/chart_screen.dart`, add this import immediately after `import 'package:flutter/material.dart';` and its blank line, before `import '../../../domain/model/category_total.dart';`:
    ```dart
    import '../../../domain/model/custom_category.dart';
    ```
15. In the same file, add the field after `final int totalExpenseCents;` — that is, replace
    ```dart
      final int totalExpenseCents;
    ```
    with:
    ```dart
      final int totalExpenseCents;
      final List<CustomCategory> customCategories;
    ```
    and, in the constructor, replace
    ```dart
        required this.totalExpenseCents,
    ```
    with:
    ```dart
        required this.totalExpenseCents,
        this.customCategories = const [],
    ```
16. In the same file, in `ChartScreen.build`, replace
    ```dart
                      child: PieChart(
                        categoryTotals: categoryTotals,
                        totalExpenseCents: totalExpenseCents,
                      ),
    ```
    with:
    ```dart
                      child: PieChart(
                        categoryTotals: categoryTotals,
                        totalExpenseCents: totalExpenseCents,
                        customCategories: customCategories,
                      ),
    ```
    and replace
    ```dart
                            child: CategoryLegend(
                              categoryTotals: categoryTotals,
                              totalExpenseCents: totalExpenseCents,
                            ),
    ```
    with:
    ```dart
                            child: CategoryLegend(
                              categoryTotals: categoryTotals,
                              totalExpenseCents: totalExpenseCents,
                              customCategories: customCategories,
                            ),
    ```
17. In `lib/presentation/ui/screens/main_screen.dart`, add these two imports next to the existing ones, keeping the file's order of `domain`, then `l10n`, then `utils`, then `presentation`:
    ```dart
    import '../../../domain/model/custom_category.dart';
    import '../../viewmodel/category_viewmodel.dart';
    ```
18. In the same file, in `MainScreen.build`, immediately after the closing `);` of the `final currentMonthYear = _formatMonthYear(...)` statement and before `return Scaffold(`, insert:
    ```dart
    final customCategories = context.watch<CategoryViewModel>().categories;
    ```
19. In the same file, replace
    ```dart
                        Expanded(
                          child: isPortrait
                              ? _TransactionContent(viewModel: viewModel)
                              : _ChartContent(
                                  viewModel: viewModel,
                                  currentMonthYear: currentMonthYear,
                                ),
                        ),
    ```
    with:
    ```dart
                        Expanded(
                          child: isPortrait
                              ? _TransactionContent(
                                  viewModel: viewModel,
                                  customCategories: customCategories,
                                )
                              : _ChartContent(
                                  viewModel: viewModel,
                                  currentMonthYear: currentMonthYear,
                                  customCategories: customCategories,
                                ),
                        ),
    ```
20. In the same file, replace
    ```dart
      final MainScreenViewModel viewModel;

      const _TransactionContent({required this.viewModel});
    ```
    with:
    ```dart
      final MainScreenViewModel viewModel;
      final List<CustomCategory> customCategories;

      const _TransactionContent({
        required this.viewModel,
        required this.customCategories,
      });
    ```
21. In the same file, in `_TransactionContent.build`, replace
    ```dart
            return TransactionList(
              items: viewModel.items,
              onDelete: (transaction) => _handleDelete(context, transaction),
            );
    ```
    with:
    ```dart
            return TransactionList(
              items: viewModel.items,
              customCategories: customCategories,
              onDelete: (transaction) => _handleDelete(context, transaction),
            );
    ```
22. In the same file, replace
    ```dart
      final MainScreenViewModel viewModel;
      final String currentMonthYear;

      const _ChartContent({
        required this.viewModel,
        required this.currentMonthYear,
      });
    ```
    with:
    ```dart
      final MainScreenViewModel viewModel;
      final String currentMonthYear;
      final List<CustomCategory> customCategories;

      const _ChartContent({
        required this.viewModel,
        required this.currentMonthYear,
        required this.customCategories,
      });
    ```
23. In the same file, in `_ChartContent.build`, replace
    ```dart
              return ChartScreen(
                categoryTotals: viewModel.expenseByCategory,
                totalExpenseCents: viewModel.totalExpenseCents,
    ```
    with:
    ```dart
              return ChartScreen(
                categoryTotals: viewModel.expenseByCategory,
                totalExpenseCents: viewModel.totalExpenseCents,
                customCategories: customCategories,
    ```
24. In `test/presentation/ui/widgets/chart/pie_chart_test.dart`, add these two imports after `import 'package:rich_ludo/domain/model/category_total.dart';`:
    ```dart
    import 'package:rich_ludo/domain/model/custom_category.dart';
    import 'package:rich_ludo/domain/model/transaction_type.dart';
    ```
25. In the same file, immediately before the final closing `}` of `main()`, insert these 2 tests:
    ```dart

      group('CategoryLegend with user-created categories', () {
        const custom = CustomCategory(
          id: 1,
          slug: 'custom_mercado',
          name: 'Mercado',
          type: TransactionType.expense,
          iconCodePoint: 0xe59c,
          colorValue: 0xFFC62828,
        );

        testWidgets('should show the stored name of a user-created slug', (
          tester,
        ) async {
          await pumpChartWidget(
            tester,
            const CategoryLegend(
              categoryTotals: [
                CategoryTotal(category: 'custom_mercado', amountCents: 5000),
              ],
              totalExpenseCents: 5000,
              customCategories: [custom],
            ),
          );

          expect(find.text('Mercado'), findsOneWidget);
        });

        testWidgets('should show the uncategorized label without the list', (
          tester,
        ) async {
          await pumpChartWidget(
            tester,
            const CategoryLegend(
              categoryTotals: [
                CategoryTotal(category: 'custom_mercado', amountCents: 5000),
              ],
              totalExpenseCents: 5000,
            ),
          );

          expect(find.text('Sem categoria'), findsOneWidget);
        });
      });
    ```
26. In `test/presentation/ui/screens/chart_screen_test.dart`, add these two imports after `import 'package:rich_ludo/domain/model/category_total.dart';`:
    ```dart
    import 'package:rich_ludo/domain/model/custom_category.dart';
    import 'package:rich_ludo/domain/model/transaction_type.dart';
    ```
27. In the same file, in the `pumpChartScreen` helper, add a parameter and forward it. Replace
    ```dart
        required String currentMonthYear,
    ```
    with:
    ```dart
        required String currentMonthYear,
        List<CustomCategory> customCategories = const [],
    ```
    and replace
    ```dart
              currentMonthYear: currentMonthYear,
              onPreviousMonth: onPreviousMonth,
    ```
    with:
    ```dart
              currentMonthYear: currentMonthYear,
              customCategories: customCategories,
              onPreviousMonth: onPreviousMonth,
    ```
28. In the same file, immediately before the final closing `}` of `main()`, insert this 1 test:
    ```dart

      group('ChartScreen with user-created categories', () {
        testWidgets('should forward the list so the legend shows the stored name', (
          tester,
        ) async {
          await pumpChartScreen(
            tester,
            categoryTotals: const [
              CategoryTotal(category: 'custom_mercado', amountCents: 5000),
            ],
            totalExpenseCents: 5000,
            totalExpenseText: 'R\$ 50.00',
            currentMonthYear: 'Agosto 2026',
            customCategories: const [
              CustomCategory(
                id: 1,
                slug: 'custom_mercado',
                name: 'Mercado',
                type: TransactionType.expense,
                iconCodePoint: 0xe59c,
                colorValue: 0xFFC62828,
              ),
            ],
          );

          expect(find.text('Mercado'), findsOneWidget);
        });
      });
    ```
29. Run the §5 `write-only` formatter on the Touches paths only:
    ```
    dart format lib/presentation/ui/widgets/transaction_card.dart lib/presentation/ui/widgets/transaction_list.dart lib/presentation/ui/widgets/chart/pie_chart.dart lib/presentation/ui/screens/chart_screen.dart lib/presentation/ui/screens/main_screen.dart test/presentation/ui/widgets/chart/pie_chart_test.dart test/presentation/ui/screens/chart_screen_test.dart
    ```

### Do not
- Do not make `TransactionCard`, `TransactionList`, `PieChart`, `CategoryLegend` or `ChartScreen` read a `Provider`. `chart_screen.dart:9` states they are pure renderers whose every value is a parameter.
- Do not remove the `= const []` default from those five public widgets; the two chart test files rely on it in their existing tests.
- Do not add a `customCategories` default to `_TransactionContent` or `_ChartContent`: both are private and `MainScreen` is their only caller, so both parameters stay `required`.
- Do not filter the list by transaction type here. `TransactionCard` renders both incomes and expenses, so it needs `categories`, not `categoriesFor(...)`.
- Do not change an existing test in either test file.
- Do not edit `lib/main.dart` — BLOCK 6 already provides `CategoryViewModel`.

### Verify
Run from the repository root, in this order:
```
flutter test test/presentation/ui/widgets/chart/pie_chart_test.dart test/presentation/ui/screens/chart_screen_test.dart
grep -c 'customCategories:' lib/presentation/ui/screens/main_screen.dart
flutter analyze
flutter test
```
Expected: the first command exits 0 and reports 3 more tests than before this block; the `grep -c` prints `4` — two in the `Expanded` at step 19, one in `TransactionList`, one in `ChartScreen`; `flutter analyze` exits 0 printing `No issues found!`; `flutter test` exits 0 and reports `All tests passed!` with 299 tests (296 after BLOCK 11, plus 3).

### If verification fails
1. Read the failing output in full.
2. Fix only the seven files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 12's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/presentation/ui/widgets/transaction_card.dart lib/presentation/ui/widgets/transaction_list.dart lib/presentation/ui/widgets/chart/pie_chart.dart lib/presentation/ui/screens/chart_screen.dart lib/presentation/ui/screens/main_screen.dart test/presentation/ui/widgets/chart/pie_chart_test.dart test/presentation/ui/screens/chart_screen_test.dart PLAN.md
   git commit -m "Render user-created categories in the transaction list and the chart"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.
