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
}
