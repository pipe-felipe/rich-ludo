import 'package:flutter/material.dart';

import '../../../domain/model/category_total.dart';
import '../../../domain/model/custom_category.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/chart/pie_chart.dart';
import '../widgets/month_selector.dart';

/// Landscape content of [MainScreen]: the selected month's expenses split
/// by category. A pure renderer — every value and callback is a parameter.
class ChartScreen extends StatelessWidget {
  final List<CategoryTotal> categoryTotals;
  final int totalExpenseCents;
  final List<CustomCategory> customCategories;
  final String totalExpenseText;
  final String currentMonthYear;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onCurrentMonthClick;

  const ChartScreen({
    super.key,
    required this.categoryTotals,
    required this.totalExpenseCents,
    this.customCategories = const [],
    required this.totalExpenseText,
    required this.currentMonthYear,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onCurrentMonthClick,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
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
                    customCategories: customCategories,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.chartTitle,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: CategoryLegend(
                          categoryTotals: categoryTotals,
                          totalExpenseCents: totalExpenseCents,
                          customCategories: customCategories,
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
    );
  }
}
