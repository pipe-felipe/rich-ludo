// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get formPrompt => 'Fill in the field below:';

  @override
  String get formTextfieldLabel => 'Text field';

  @override
  String get formSubmitButton => 'Submit';

  @override
  String get formCloseButtonDescription => 'Close';

  @override
  String get formDateLabel => 'Date';

  @override
  String get formCategoryLabel => 'Category';

  @override
  String get formQuantityLabel => 'R\$ Amount';

  @override
  String get formNotesLabel => 'Notes';

  @override
  String get formRecurringLabel => 'Recurring';

  @override
  String get transactionTypeExpense => 'Expense';

  @override
  String get transactionTypeIncome => 'Income';

  @override
  String get expenseCategoryTransport => 'Transport';

  @override
  String get expenseCategoryGift => 'Gift';

  @override
  String get expenseCategoryRecurring => 'Recurring';

  @override
  String get expenseCategoryFood => 'Food';

  @override
  String get expenseCategoryStuff => 'Stuff';

  @override
  String get expenseCategoryMedicine => 'Medicine';

  @override
  String get expenseCategoryClothes => 'Clothes';

  @override
  String get income => 'Income';

  @override
  String get saving => 'Savings';

  @override
  String get outgoing => 'Expenses';

  @override
  String get incomeCategorySalary => 'Salary';

  @override
  String get incomeCategoryGift => 'Gift';

  @override
  String get incomeCategoryInvestment => 'Investment';

  @override
  String get incomeCategoryOther => 'Other';

  @override
  String get labelInvalidNumber => 'Invalid Number';

  @override
  String get noTransaction => 'No transactions to display';

  @override
  String get errorLoading => 'Error loading data';

  @override
  String get tryAgain => 'Try again';
}
