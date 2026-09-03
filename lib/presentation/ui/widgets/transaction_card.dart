import 'package:flutter/material.dart';

import '../../../domain/model/custom_category.dart';
import '../../../domain/model/transaction.dart';
import '../../../domain/model/transaction_type.dart';
import '../../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/category_icon.dart';
import '../utils/money_formatter.dart';

class TransactionCard extends StatelessWidget {
  final Transaction item;
  final List<CustomCategory> customCategories;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionCard({
    super.key,
    required this.item,
    this.customCategories = const [],
    required this.onEdit,
    required this.onDelete,
  });

  bool get _isIncome => item.type == TransactionType.income;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isIncome
        ? AppTheme.incomeBackground(context)
        : AppTheme.expenseBackground(context);
    final iconColor = _isIncome
        ? AppTheme.moneyColor(context)
        : Theme.of(context).colorScheme.error;

    return Card(
      color: backgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Semantics(
        label: AppLocalizations.of(context)!.transactionEditTooltip,
        button: true,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
            child: Row(
              children: [
                _CategoryIcon(
                  category: item.category,
                  customCategories: customCategories,
                  isIncome: _isIncome,
                  iconColor: iconColor,
                ),
                const SizedBox(width: 12),
                _TransactionDetails(
                  description: item.description,
                  humanDate: item.humanDate,
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: _AmountText(
                      amountCents: item.amountCents,
                      isIncome: _isIncome,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.delete, color: AppTheme.thrashCan(context)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        getCategoryIcon(
          category,
          isIncome: isIncome,
          customCategories: customCategories,
        ),
        size: 24,
        color: iconColor,
      ),
    );
  }
}

class _TransactionDetails extends StatelessWidget {
  final String? description;
  final String humanDate;

  const _TransactionDetails({
    required this.description,
    required this.humanDate,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description != null && description!.isNotEmpty)
            Text(description!, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(humanDate, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _AmountText extends StatelessWidget {
  final int amountCents;
  final bool isIncome;

  const _AmountText({required this.amountCents, required this.isIncome});

  @override
  Widget build(BuildContext context) {
    final formattedAmount = formatMoney(amountCents);
    final text = isIncome ? 'R\$$formattedAmount' : '-R\$$formattedAmount';

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
