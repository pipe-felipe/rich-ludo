import 'package:flutter_test/flutter_test.dart';
import 'package:rich_ludo/domain/model/month_year.dart';

void main() {
  group('MonthYear', () {
    test('next should advance the month inside the same year', () {
      expect(const MonthYear(3, 2026).next, equals(const MonthYear(4, 2026)));
    });

    test('next should roll December into January of the following year', () {
      expect(const MonthYear(12, 2026).next, equals(const MonthYear(1, 2027)));
    });

    test('previous should step back inside the same year', () {
      expect(
        const MonthYear(3, 2026).previous,
        equals(const MonthYear(2, 2026)),
      );
    });

    test('previous should roll January into December of the previous year', () {
      expect(
        const MonthYear(1, 2026).previous,
        equals(const MonthYear(12, 2025)),
      );
    });

    test('isAfter should compare the year before the month', () {
      expect(
        const MonthYear(1, 2027).isAfter(const MonthYear(12, 2026)),
        isTrue,
      );
      expect(
        const MonthYear(12, 2026).isAfter(const MonthYear(1, 2027)),
        isFalse,
      );
    });

    test('isBefore should compare the year before the month', () {
      expect(
        const MonthYear(12, 2026).isBefore(const MonthYear(1, 2027)),
        isTrue,
      );
      expect(
        const MonthYear(1, 2027).isBefore(const MonthYear(12, 2026)),
        isFalse,
      );
    });

    test('isAfter and isBefore should both be false for the same pair', () {
      const pair = MonthYear(6, 2026);

      expect(pair.isAfter(pair), isFalse);
      expect(pair.isBefore(pair), isFalse);
    });

    test(
      'equality should hold for equal values and fail for different ones',
      () {
        const a = MonthYear(6, 2026);
        const b = MonthYear(6, 2026);
        const c = MonthYear(7, 2026);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
        expect(a, isNot(equals(c)));
      },
    );
  });
}
