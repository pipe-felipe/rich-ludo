import 'package:flutter_test/flutter_test.dart';
import 'package:rich_ludo/domain/model/custom_category.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
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
      ExpenseCategory.medicine: 'Medicine',
      ExpenseCategory.clothes: 'Clothes',
      ExpenseCategory.hygiene: 'Hygiene',
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

  group('getExpenseCategoryLabel with user-created categories', () {
    const custom = CustomCategory(
      id: 1,
      slug: 'custom_mercado',
      name: 'Mercado',
      type: TransactionType.expense,
      iconCodePoint: 0xe59c,
      colorValue: 0xFFC62828,
    );

    test('should return the stored name for a user-created slug', () {
      expect(
        getExpenseCategoryLabel(
          'custom_mercado',
          l10n,
          customCategories: const [custom],
        ),
        equals('Mercado'),
      );
    });

    test(
      'should still resolve a built-in name when a custom list is given',
      () {
        expect(
          getExpenseCategoryLabel(
            'food',
            l10n,
            customCategories: const [custom],
          ),
          equals(mapExpenseCategory(ExpenseCategory.food, l10n)),
        );
      },
    );

    test('should fall back to uncategorized for a deleted user slug', () {
      expect(
        getExpenseCategoryLabel(
          'custom_removida',
          l10n,
          customCategories: const [],
        ),
        equals(l10n.categoryUncategorized),
      );
    });
  });
}
