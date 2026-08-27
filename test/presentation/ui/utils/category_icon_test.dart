import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_ludo/domain/model/custom_category.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/presentation/ui/utils/category_icon.dart';
import 'package:rich_ludo/presentation/viewmodel/transaction_form_viewmodel.dart';

void main() {
  group('ExpenseCategoryIcon', () {
    final expectedIcons = {
      ExpenseCategory.transport: Icons.directions_car,
      ExpenseCategory.gift: Icons.card_giftcard,
      ExpenseCategory.recurring: Icons.repeat,
      ExpenseCategory.food: Icons.restaurant,
      ExpenseCategory.stuff: Icons.shopping_bag,
      ExpenseCategory.medicine: Icons.medical_services,
      ExpenseCategory.clothes: Icons.checkroom,
      ExpenseCategory.hygiene: Icons.clean_hands,
      ExpenseCategory.care: Icons.favorite,
    };

    test('should map all enum values', () {
      expect(expectedIcons.length, equals(ExpenseCategory.values.length));
    });

    for (final entry in expectedIcons.entries) {
      test('should return ${entry.value} for ${entry.key.name}', () {
        expect(entry.key.icon, equals(entry.value));
      });
    }
  });

  group('IncomeCategoryIcon', () {
    final expectedIcons = {
      IncomeCategory.salary: Icons.payments,
      IncomeCategory.gift: Icons.card_giftcard,
      IncomeCategory.investment: Icons.trending_up,
      IncomeCategory.other: Icons.attach_money,
    };

    test('should map all enum values', () {
      expect(expectedIcons.length, equals(IncomeCategory.values.length));
    });

    for (final entry in expectedIcons.entries) {
      test('should return ${entry.value} for ${entry.key.name}', () {
        expect(entry.key.icon, equals(entry.value));
      });
    }
  });

  group('getCategoryIcon', () {
    group('expenses', () {
      for (final category in ExpenseCategory.values) {
        test('should return correct icon for "${category.name}"', () {
          final result = getCategoryIcon(category.name, isIncome: false);
          expect(result, equals(category.icon));
        });
      }
    });

    group('incomes', () {
      for (final category in IncomeCategory.values) {
        test('should return correct icon for "${category.name}"', () {
          final result = getCategoryIcon(category.name, isIncome: true);
          expect(result, equals(category.icon));
        });
      }
    });

    group('null category', () {
      test('should return Icons.money_off when expense and null', () {
        expect(getCategoryIcon(null, isIncome: false), equals(Icons.money_off));
      });

      test('should return Icons.attach_money when income and null', () {
        expect(
          getCategoryIcon(null, isIncome: true),
          equals(Icons.attach_money),
        );
      });
    });

    group('unknown category', () {
      test('should return default expense icon for invalid string', () {
        expect(
          getCategoryIcon('inexistente', isIncome: false),
          equals(Icons.money_off),
        );
      });

      test('should return default income icon for invalid string', () {
        expect(
          getCategoryIcon('inexistente', isIncome: true),
          equals(Icons.attach_money),
        );
      });
    });
  });

  group('customCategoryIcons', () {
    test('should offer 24 icons', () {
      expect(customCategoryIcons, hasLength(24));
    });

    test('should give every entry a distinct code point', () {
      final codePoints = customCategoryIcons
          .map((icon) => icon.codePoint)
          .toSet();

      expect(codePoints, hasLength(customCategoryIcons.length));
    });
  });

  group('resolveCustomCategoryIcon', () {
    test('should return the matching const icon', () {
      expect(
        resolveCustomCategoryIcon(Icons.shopping_cart.codePoint),
        equals(Icons.shopping_cart),
      );
    });

    test('should return the first icon for an unknown code point', () {
      expect(resolveCustomCategoryIcon(1), equals(customCategoryIcons.first));
    });
  });

  group('getCategoryIcon with user-created categories', () {
    const custom = CustomCategory(
      id: 1,
      slug: 'custom_mercado',
      name: 'Mercado',
      type: TransactionType.expense,
      iconCodePoint: 0xe59c,
      colorValue: 0xFFC62828,
    );

    test('should return the stored icon for a user-created slug', () {
      expect(
        getCategoryIcon(
          'custom_mercado',
          isIncome: false,
          customCategories: const [custom],
        ),
        equals(Icons.shopping_cart),
      );
    });

    test(
      'should still resolve a built-in name when a custom list is given',
      () {
        expect(
          getCategoryIcon(
            'food',
            isIncome: false,
            customCategories: const [custom],
          ),
          equals(ExpenseCategory.food.icon),
        );
      },
    );
  });
}
