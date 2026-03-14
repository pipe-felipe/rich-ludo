import 'package:flutter/material.dart';

import '../../viewmodel/transaction_form_viewmodel.dart';

/// Exhaustive icon mapping for [ExpenseCategory].
extension ExpenseCategoryIcon on ExpenseCategory {
  IconData get icon => switch (this) {
    ExpenseCategory.transport => Icons.directions_car,
    ExpenseCategory.gift => Icons.card_giftcard,
    ExpenseCategory.recurring => Icons.repeat,
    ExpenseCategory.food => Icons.restaurant,
    ExpenseCategory.stuff => Icons.shopping_bag,
    ExpenseCategory.medicine => Icons.medical_services,
    ExpenseCategory.clothes => Icons.checkroom,
    ExpenseCategory.hygiene => Icons.clean_hands,
    ExpenseCategory.care => Icons.favorite,
  };
}

/// Exhaustive icon mapping for [IncomeCategory].
extension IncomeCategoryIcon on IncomeCategory {
  IconData get icon => switch (this) {
    IncomeCategory.salary => Icons.payments,
    IncomeCategory.gift => Icons.card_giftcard,
    IncomeCategory.investment => Icons.trending_up,
    IncomeCategory.other => Icons.attach_money,
  };
}

/// Resolves icon from a [String] category (used by [Transaction] model).
/// Delegates to the exhaustive enum extensions above.
IconData getCategoryIcon(String? category, {required bool isIncome}) {
  if (category == null) {
    return _defaultIcon(isIncome);
  }

  if (isIncome) {
    final parsed = IncomeCategory.values
        .where((e) => e.name == category)
        .firstOrNull;
    return parsed?.icon ?? _defaultIcon(true);
  }

  final parsed = ExpenseCategory.values
      .where((e) => e.name == category)
      .firstOrNull;
  return parsed?.icon ?? _defaultIcon(false);
}

IconData _defaultIcon(bool isIncome) =>
    isIncome ? Icons.attach_money : Icons.money_off;

