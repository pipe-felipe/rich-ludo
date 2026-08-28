import 'package:flutter_test/flutter_test.dart';
import 'package:rich_ludo/domain/model/custom_category.dart';
import 'package:rich_ludo/domain/model/custom_category_mapper.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/presentation/viewmodel/transaction_form_viewmodel.dart';

void main() {
  group('CustomCategory.slugFor', () {
    test('should lowercase and prefix a simple name', () {
      expect(CustomCategory.slugFor('Mercado'), equals('custom_mercado'));
    });

    test('should replace every run of spaces with one underscore', () {
      expect(
        CustomCategory.slugFor('Mercado   Municipal'),
        equals('custom_mercado_municipal'),
      );
    });

    test('should strip Portuguese accents', () {
      expect(
        CustomCategory.slugFor('Alimentação e Saúde'),
        equals('custom_alimentacao_e_saude'),
      );
    });

    test('should trim leading and trailing separators', () {
      expect(CustomCategory.slugFor('  -Casa-  '), equals('custom_casa'));
    });

    test(
      'should return the bare prefix for a name with no letter or digit',
      () {
        expect(
          CustomCategory.slugFor('   '),
          equals(CustomCategory.slugPrefix),
        );
      },
    );

    test('should never collide with a built-in expense category name', () {
      for (final category in ExpenseCategory.values) {
        expect(
          CustomCategory.slugFor(category.name),
          isNot(equals(category.name)),
        );
      }
    });

    test('should never collide with a built-in income category name', () {
      for (final category in IncomeCategory.values) {
        expect(
          CustomCategory.slugFor(category.name),
          isNot(equals(category.name)),
        );
      }
    });
  });

  group('CustomCategory.draft', () {
    test('should derive the slug and trim the name', () {
      final draft = CustomCategory.draft(
        name: '  Mercado  ',
        type: TransactionType.expense,
        iconCodePoint: 0xe59c,
        colorValue: 0xFFC62828,
      );

      expect(draft.slug, equals('custom_mercado'));
      expect(draft.name, equals('Mercado'));
      expect(draft.id, equals(0));
      expect(draft.createdAt, equals(0));
    });
  });

  group('CustomCategory', () {
    const category = CustomCategory(
      id: 7,
      slug: 'custom_mercado',
      name: 'Mercado',
      type: TransactionType.expense,
      iconCodePoint: 0xe59c,
      colorValue: 0xFFC62828,
      createdAt: 1756166400000,
    );

    test('copyWith should change only the given field', () {
      final renamed = category.copyWith(name: 'Feira');

      expect(renamed.name, equals('Feira'));
      expect(renamed.slug, equals('custom_mercado'));
      expect(renamed.id, equals(7));
    });

    test('equality should hold for equal values', () {
      expect(category.copyWith(), equals(category));
      expect(category.copyWith().hashCode, equals(category.hashCode));
    });

    test('equality should fail for a different colorValue', () {
      expect(
        category.copyWith(colorValue: 0xFF2E7D32),
        isNot(equals(category)),
      );
    });
  });

  group('CustomCategoryMapper', () {
    test('toMap should encode the type and omit the id', () {
      const category = CustomCategory(
        id: 7,
        slug: 'custom_bonus',
        name: 'Bonus',
        type: TransactionType.income,
        iconCodePoint: 0xe553,
        colorValue: 0xFF2E7D32,
        createdAt: 1756166400000,
      );

      final map = CustomCategoryMapper.toMap(category);

      expect(map['type'], equals('income'));
      expect(map['slug'], equals('custom_bonus'));
      expect(map.containsKey('id'), isFalse);
    });

    test('fromMap should decode a row of the categories table', () {
      final category = CustomCategoryMapper.fromMap({
        'id': 7,
        'slug': 'custom_mercado',
        'name': 'Mercado',
        'type': 'expense',
        'iconCodePoint': 0xe59c,
        'colorValue': 0xFFC62828,
        'createdAt': 1756166400000,
      });

      expect(category.id, equals(7));
      expect(category.type, equals(TransactionType.expense));
      expect(category.iconCodePoint, equals(0xe59c));
      expect(category.colorValue, equals(0xFFC62828));
    });
  });
}
