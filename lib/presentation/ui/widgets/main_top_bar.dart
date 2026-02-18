import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class MainTopBar extends StatelessWidget {
  final String totalIncomeText;
  final String totalExpenseText;
  final String totalSavingText;
  final int totalIncomeCents;
  final int totalExpenseCents;
  final String currentMonthYear;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onCurrentMonthClick;

  const MainTopBar({
    super.key,
    required this.totalIncomeText,
    required this.totalExpenseText,
    required this.totalSavingText,
    required this.totalIncomeCents,
    required this.totalExpenseCents,
    required this.currentMonthYear,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onCurrentMonthClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Column(
        children: [
          _MonthSelector(
            currentMonthYear: currentMonthYear,
            onPreviousMonth: onPreviousMonth,
            onNextMonth: onNextMonth,
            onCurrentMonthClick: onCurrentMonthClick,
          ),
          _SummaryRow(
            totalIncomeText: totalIncomeText,
            totalExpenseText: totalExpenseText,
            totalSavingText: totalSavingText,
          ),
          _IncomeExpenseBar(
            incomeCents: totalIncomeCents,
            expenseCents: totalExpenseCents,
          ),
        ],
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final String currentMonthYear;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onCurrentMonthClick;

  const _MonthSelector({
    required this.currentMonthYear,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onCurrentMonthClick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPreviousMonth,
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        TextButton(
          onPressed: onCurrentMonthClick,
          child: Text(
            currentMonthYear,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          onPressed: onNextMonth,
          icon: Icon(
            Icons.keyboard_arrow_right,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String totalIncomeText;
  final String totalExpenseText;
  final String totalSavingText;

  const _SummaryRow({
    required this.totalIncomeText,
    required this.totalExpenseText,
    required this.totalSavingText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SummaryItem(
            icon: Icons.arrow_downward,
            iconColor: AppTheme.moneyColor(context),
            label: l10n.income,
            value: totalIncomeText,
            alignment: CrossAxisAlignment.start,
          ),
          _SummaryItem(
            icon: Icons.savings,
            iconColor: AppTheme.goldenColor(),
            label: l10n.saving,
            value: totalSavingText,
            alignment: CrossAxisAlignment.center,
          ),
          _SummaryItem(
            icon: Icons.arrow_upward,
            iconColor: Theme.of(context).colorScheme.error,
            label: l10n.outgoing,
            value: totalExpenseText,
            alignment: CrossAxisAlignment.end,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final CrossAxisAlignment alignment;

  const _SummaryItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.alignment,
  });

  TextAlign get _textAlign => switch (alignment) {
    CrossAxisAlignment.start => TextAlign.start,
    CrossAxisAlignment.end => TextAlign.end,
    _ => TextAlign.center,
  };

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: _textAlign,
              ),
            ],
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: iconColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: _textAlign,
          ),
        ],
      ),
    );
  }
}

class _IncomeExpenseBar extends StatelessWidget {
  final int incomeCents;
  final int expenseCents;

  const _IncomeExpenseBar({
    required this.incomeCents,
    required this.expenseCents,
  });

  @override
  Widget build(BuildContext context) {
    final total = incomeCents + expenseCents;
    if (total == 0) {
      return const SizedBox(height: 4);
    }
    return SizedBox(
      height: 4,
      child: Row(
        children: [
          if (incomeCents > 0)
            Flexible(
              flex: incomeCents,
              child: Container(color: AppTheme.moneyColor(context)),
            ),
          if (expenseCents > 0)
            Flexible(
              flex: expenseCents,
              child: Container(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
    );
  }
}
