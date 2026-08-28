import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_ludo/domain/model/custom_category.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/presentation/ui/theme/app_colors.dart';
import 'package:rich_ludo/presentation/ui/utils/category_color.dart';
import 'package:rich_ludo/presentation/viewmodel/transaction_form_viewmodel.dart';

void main() {
  group('ExpenseCategoryColor', () {
    const expectedColors = <ExpenseCategory, Color>{
      ExpenseCategory.transport: CategoryPiColors.transport,
      ExpenseCategory.gift: CategoryPiColors.gift,
      ExpenseCategory.recurring: CategoryPiColors.recurring,
      ExpenseCategory.food: CategoryPiColors.food,
      ExpenseCategory.medicine: CategoryPiColors.medicine,
      ExpenseCategory.clothes: CategoryPiColors.clothes,
      ExpenseCategory.hygiene: CategoryPiColors.hygiene,
    };

    test('should map all enum values', () {
      expect(expectedColors.length, equals(ExpenseCategory.values.length));
    });

    for (final entry in expectedColors.entries) {
      test('should return ${entry.value} for ${entry.key.name}', () {
        expect(entry.key.color, equals(entry.value));
      });
    }

    test('should give every expense category a distinct color', () {
      expect(expectedColors.values.toSet().length, equals(7));
    });
  });

  group('getExpenseCategoryColor', () {
    for (final category in ExpenseCategory.values) {
      test('should return the correct color for "${category.name}"', () {
        final result = getExpenseCategoryColor(category.name);
        expect(result, equals(category.color));
      });
    }

    test('should return the uncategorized color when the category is null', () {
      expect(
        getExpenseCategoryColor(null),
        equals(CategoryPiColors.uncategorized),
      );
    });

    test('should return the uncategorized color for an unknown string', () {
      expect(
        getExpenseCategoryColor('not-a-category'),
        equals(CategoryPiColors.uncategorized),
      );
    });
  });

  group('CategoryPiColors.customPalette', () {
    test('should offer 8 colors', () {
      expect(CategoryPiColors.customPalette, hasLength(8));
    });

    test('should give every entry a distinct value', () {
      expect(CategoryPiColors.customPalette.toSet(), hasLength(8));
    });
  });

  group('getExpenseCategoryColor with user-created categories', () {
    const custom = CustomCategory(
      id: 1,
      slug: 'custom_mercado',
      name: 'Mercado',
      type: TransactionType.expense,
      iconCodePoint: 0xe59c,
      colorValue: 0xFFC62828,
    );

    test('should return the stored color for a user-created slug', () {
      expect(
        getExpenseCategoryColor(
          'custom_mercado',
          customCategories: const [custom],
        ),
        equals(const Color(0xFFC62828)),
      );
    });

    test(
      'should still resolve a built-in name when a custom list is given',
      () {
        expect(
          getExpenseCategoryColor('food', customCategories: const [custom]),
          equals(ExpenseCategory.food.color),
        );
      },
    );
  });
}
