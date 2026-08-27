import 'package:flutter/material.dart';

import '../../../domain/model/custom_category.dart';
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
/// enum extension above, or to the stored color of a user-created slug.
Color getExpenseCategoryColor(
  String? category, {
  List<CustomCategory> customCategories = const [],
}) {
  if (category == null) {
    return CategoryPiColors.uncategorized;
  }

  final custom = customCategories
      .where((entry) => entry.slug == category)
      .firstOrNull;
  if (custom != null) {
    return Color(custom.colorValue);
  }

  final parsed = ExpenseCategory.values
      .where((e) => e.name == category)
      .firstOrNull;
  return parsed?.color ?? CategoryPiColors.uncategorized;
}
