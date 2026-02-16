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
