import 'package:flutter/material.dart';

import '../../viewmodel/transaction_form_viewmodel.dart';
import '../theme/app_colors.dart';

/// Exhaustive color mapping for [ExpenseCategory].
extension ExpenseCategoryColor on ExpenseCategory {
  Color get color => switch (this) {
    ExpenseCategory.transport => CategoryPiColors.transport,
    ExpenseCategory.gift => CategoryPiColors.gift,
    ExpenseCategory.recurring => CategoryPiColors.recurring,
    ExpenseCategory.food => CategoryPiColors.food,
    ExpenseCategory.stuff => CategoryPiColors.stuff,
    ExpenseCategory.medicine => CategoryPiColors.medicine,
    ExpenseCategory.clothes => CategoryPiColors.clothes,
    ExpenseCategory.hygiene => CategoryPiColors.hygiene,
    ExpenseCategory.care => CategoryPiColors.care,
  };
}

/// Resolves the chart slice color from a [String] category
/// (used by the `Transaction` model). Delegates to the exhaustive
/// enum extension above.
Color getExpenseCategoryColor(String? category) {
  if (category == null) {
    return CategoryPiColors.uncategorized;
  }

  final parsed = ExpenseCategory.values
      .where((e) => e.name == category)
      .firstOrNull;
  return parsed?.color ?? CategoryPiColors.uncategorized;
}
