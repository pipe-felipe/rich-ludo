import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
      ExpenseCategory.stuff: CategoryPiColors.stuff,
      ExpenseCategory.medicine: CategoryPiColors.medicine,
      ExpenseCategory.clothes: CategoryPiColors.clothes,
      ExpenseCategory.hygiene: CategoryPiColors.hygiene,
      ExpenseCategory.care: CategoryPiColors.care,
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
      expect(expectedColors.values.toSet().length, equals(9));
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
}
