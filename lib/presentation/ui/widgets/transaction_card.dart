import 'package:flutter/material.dart';

import '../../../domain/model/transaction.dart';
import '../../../domain/model/transaction_type.dart';
import '../theme/app_theme.dart';
import '../utils/category_icon.dart';
import '../utils/money_formatter.dart';

class TransactionCard extends StatelessWidget {
  final Transaction item;
  final VoidCallback onDelete;

  const TransactionCard({
    super.key,
    required this.item,
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _CategoryIcon(
              category: item.category,
              isIncome: _isIncome,
              iconColor: iconColor,
            ),
            const SizedBox(width: 12),
            _TransactionDetails(
              description: item.description,
              humanDate: item.humanDate,
            ),
            _AmountText(
              amountCents: item.amountCents,
              isIncome: _isIncome,
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final String? category;
  final bool isIncome;
  final Color iconColor;

  const _CategoryIcon({
    required this.category,
    required this.isIncome,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        getCategoryIcon(category, isIncome: isIncome),
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
            Text(
              description!,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          const SizedBox(height: 4),
          Text(
            humanDate,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _AmountText extends StatelessWidget {
  final int amountCents;
  final bool isIncome;

  const _AmountText({
    required this.amountCents,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = formatMoney(amountCents);
    final text = isIncome ? 'R\$$formattedAmount' : '-R\$$formattedAmount';

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
