import 'package:flutter/material.dart';

import '../../../domain/model/custom_category.dart';
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

/// Icons the user may pick when creating a category.
///
/// The list is fixed and `const` on purpose: `flutter build apk --release`
/// tree-shakes the Material icon font down to the icons it can see at
/// compile time. Building an `IconData` from a stored code point at runtime
/// would make the picked icon render as a blank box in a release build.
const List<IconData> customCategoryIcons = [
  Icons.label,
  Icons.shopping_cart,
  Icons.home,
  Icons.pets,
  Icons.school,
  Icons.fitness_center,
  Icons.local_bar,
  Icons.local_cafe,
  Icons.flight,
  Icons.hotel,
  Icons.sports_esports,
  Icons.movie,
  Icons.music_note,
  Icons.book,
  Icons.build,
  Icons.computer,
  Icons.phone_android,
  Icons.wifi,
  Icons.bolt,
  Icons.water_drop,
  Icons.local_gas_station,
  Icons.savings,
  Icons.credit_card,
  Icons.child_care,
];

/// Resolves a stored `iconCodePoint` back to its `const` entry of
/// [customCategoryIcons]. A code point that is not in the list falls back to
/// the first entry, so a row written by a future version still renders.
IconData resolveCustomCategoryIcon(int codePoint) {
  for (final icon in customCategoryIcons) {
    if (icon.codePoint == codePoint) return icon;
  }
  return customCategoryIcons.first;
}

/// Resolves icon from a [String] category (used by [Transaction] model).
/// Delegates to the exhaustive enum extensions above, or to
/// [resolveCustomCategoryIcon] when [category] is a user-created slug.
IconData getCategoryIcon(
  String? category, {
  required bool isIncome,
  List<CustomCategory> customCategories = const [],
}) {
  if (category == null) {
    return _defaultIcon(isIncome);
  }

  final custom = customCategories
      .where((entry) => entry.slug == category)
      .firstOrNull;
  if (custom != null) {
    return resolveCustomCategoryIcon(custom.iconCodePoint);
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
