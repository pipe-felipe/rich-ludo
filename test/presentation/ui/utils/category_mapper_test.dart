import 'package:flutter_test/flutter_test.dart';
import 'package:rich_ludo/l10n/app_localizations.dart';
import 'package:rich_ludo/l10n/app_localizations_en.dart';
import 'package:rich_ludo/presentation/ui/utils/category_mapper.dart';
import 'package:rich_ludo/presentation/viewmodel/transaction_form_viewmodel.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() {
    l10n = AppLocalizationsEn();
  });

  group('mapExpenseCategory', () {
    final expectedLabels = {
      ExpenseCategory.transport: 'Transport',
      ExpenseCategory.gift: 'Gift',
      ExpenseCategory.recurring: 'Recurring',
      ExpenseCategory.food: 'Food',
      ExpenseCategory.stuff: 'Stuff',
      ExpenseCategory.medicine: 'Medicine',
      ExpenseCategory.clothes: 'Clothes',
      ExpenseCategory.hygiene: 'Hygiene',
      ExpenseCategory.care: 'Care',
    };

    test('should map all enum values', () {
      expect(expectedLabels.length, equals(ExpenseCategory.values.length));
    });

    for (final entry in expectedLabels.entries) {
      test('should return "${entry.value}" for ${entry.key.name}', () {
        expect(mapExpenseCategory(entry.key, l10n), equals(entry.value));
      });
    }
  });

  group('mapIncomeCategory', () {
    final expectedLabels = {
      IncomeCategory.salary: 'Salary',
      IncomeCategory.gift: 'Gift',
      IncomeCategory.investment: 'Investment',
      IncomeCategory.other: 'Other',
    };

    test('should map all enum values', () {
      expect(expectedLabels.length, equals(IncomeCategory.values.length));
    });

    for (final entry in expectedLabels.entries) {
      test('should return "${entry.value}" for ${entry.key.name}', () {
        expect(mapIncomeCategory(entry.key, l10n), equals(entry.value));
      });
    }
  });

  group('getExpenseCategoryLabel', () {
    test('should return the localized name for a known category', () {
      expect(
        getExpenseCategoryLabel('food', l10n),
        equals(mapExpenseCategory(ExpenseCategory.food, l10n)),
      );
    });

    test('should return the uncategorized label when the category is null', () {
      expect(
        getExpenseCategoryLabel(null, l10n),
        equals(l10n.categoryUncategorized),
      );
    });

    test('should return the uncategorized label for an unknown string', () {
      expect(
        getExpenseCategoryLabel('not-a-category', l10n),
        equals(l10n.categoryUncategorized),
      );
    });
  });
}
