import 'package:flutter_test/flutter_test.dart';
import 'package:rich_ludo/domain/model/category_total.dart';

void main() {
  group('CategoryTotal', () {
    test('should create a category total with the given values', () {
      final categoryTotal = CategoryTotal(category: 'food', amountCents: 1500);

      expect(categoryTotal.category, equals('food'));
      expect(categoryTotal.amountCents, equals(1500));
    });

    test('should accept a null category', () {
      final categoryTotal = CategoryTotal(category: null, amountCents: 200);

      expect(categoryTotal.category, isNull);
    });

    test('copyWith should change only the given field', () {
      final original = CategoryTotal(category: 'food', amountCents: 1500);

      final copy = original.copyWith(amountCents: 900);

      expect(copy.category, equals('food'));
      expect(copy.amountCents, equals(900));
    });

    test('copyWith should set the category to null', () {
      final original = CategoryTotal(category: 'food', amountCents: 1500);

      final copy = original.copyWith(category: () => null);

      expect(copy.category, isNull);
      expect(copy.amountCents, equals(1500));
    });

    test(
      'equality should hold for equal values and fail for different ones',
      () {
        final a = CategoryTotal(category: 'food', amountCents: 1500);
        final b = CategoryTotal(category: 'food', amountCents: 1500);
        final c = CategoryTotal(category: 'food', amountCents: 1501);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
        expect(a, isNot(equals(c)));
      },
    );
  });
}
