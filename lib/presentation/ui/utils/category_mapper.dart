import '../../../domain/model/custom_category.dart';
import '../../../l10n/app_localizations.dart';
import '../../viewmodel/transaction_form_viewmodel.dart';

String mapExpenseCategory(ExpenseCategory category, AppLocalizations l10n) {
  switch (category) {
    case ExpenseCategory.transport:
      return l10n.expenseCategoryTransport;
    case ExpenseCategory.gift:
      return l10n.expenseCategoryGift;
    case ExpenseCategory.recurring:
      return l10n.expenseCategoryRecurring;
    case ExpenseCategory.food:
      return l10n.expenseCategoryFood;
    case ExpenseCategory.stuff:
      return l10n.expenseCategoryStuff;
    case ExpenseCategory.medicine:
      return l10n.expenseCategoryMedicine;
    case ExpenseCategory.clothes:
      return l10n.expenseCategoryClothes;
    case ExpenseCategory.hygiene:
      return l10n.expenseCategoryHygiene;
    case ExpenseCategory.care:
      return l10n.expenseCategoryCare;
  }
}

String mapIncomeCategory(IncomeCategory category, AppLocalizations l10n) {
  switch (category) {
    case IncomeCategory.salary:
      return l10n.incomeCategorySalary;
    case IncomeCategory.gift:
      return l10n.incomeCategoryGift;
    case IncomeCategory.investment:
      return l10n.incomeCategoryInvestment;
    case IncomeCategory.other:
      return l10n.incomeCategoryOther;
  }
}

/// Resolves the localized expense category name from a [String] category
/// (used by the `Transaction` model). Delegates to [mapExpenseCategory].
/// A user-created slug resolves to its stored name, which the user typed and
/// which is therefore not localized. A null or unknown value falls back to
/// the "no category" label.
String getExpenseCategoryLabel(
  String? category,
  AppLocalizations l10n, {
  List<CustomCategory> customCategories = const [],
}) {
  if (category == null) {
    return l10n.categoryUncategorized;
  }

  final custom = customCategories
      .where((entry) => entry.slug == category)
      .firstOrNull;
  if (custom != null) {
    return custom.name;
  }

  final parsed = ExpenseCategory.values
      .where((e) => e.name == category)
      .firstOrNull;
  return parsed == null
      ? l10n.categoryUncategorized
      : mapExpenseCategory(parsed, l10n);
}
