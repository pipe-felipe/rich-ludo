import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
        expect(
          getCategoryIcon(null, isIncome: false),
          equals(Icons.money_off),
        );
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
}
