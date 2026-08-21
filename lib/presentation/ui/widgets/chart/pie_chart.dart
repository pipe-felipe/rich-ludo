import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';

import '../../../../domain/model/category_total.dart';
import '../../../../l10n/app_localizations.dart';
import '../../utils/category_color.dart';
import '../../utils/category_mapper.dart';
import '../../utils/money_formatter.dart';

/// Share of [amountCents] in [totalCents], rounded to a whole percent.
int categoryPercentage(int amountCents, int totalCents) {
  if (totalCents <= 0) return 0;
  return ((amountCents * 100) / totalCents).round();
}

class PieChart extends StatefulWidget {
  final List<CategoryTotal> categoryTotals;
  final int totalExpenseCents;

  const PieChart({
    super.key,
    required this.categoryTotals,
    required this.totalExpenseCents,
  });

  @override
  State<PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: fl.PieChart(
        fl.PieChartData(
          pieTouchData: fl.PieTouchData(
            touchCallback: (fl.FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: fl.FlBorderData(show: false),
          sectionsSpace: 0,
          centerSpaceRadius: 40,
          sections: _buildSections(),
        ),
      ),
    );
  }

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
}

class CategoryLegend extends StatelessWidget {
  final List<CategoryTotal> categoryTotals;
  final int totalExpenseCents;

  const CategoryLegend({
    super.key,
    required this.categoryTotals,
    required this.totalExpenseCents,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView.separated(
      itemCount: categoryTotals.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final total = categoryTotals[index];

        return _Indicator(
          color: getExpenseCategoryColor(total.category),
          label: getExpenseCategoryLabel(total.category, l10n),
          value: 'R\$ ${formatMoney(total.amountCents)}',
          percentage: categoryPercentage(total.amountCents, totalExpenseCents),
        );
      },
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final int percentage;

  const _Indicator({
    required this.color,
    required this.label,
    required this.value,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(shape: BoxShape.rectangle, color: color),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$value  ($percentage%)',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
