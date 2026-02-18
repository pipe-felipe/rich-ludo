import 'package:flutter_test/flutter_test.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';

void main() {
  group('Transaction', () {
    test('deve criar transação com valores padrão', () {
      final transaction = Transaction(
        amountCents: 1000,
        type: TransactionType.income,
      );

      expect(transaction.id, equals(0));
      expect(transaction.amountCents, equals(1000));
      expect(transaction.type, equals(TransactionType.income));
      expect(transaction.category, isNull);
      expect(transaction.description, isNull);
      expect(transaction.humanDate, equals(''));
      expect(transaction.isRecurring, isFalse);
      expect(transaction.createdAt, equals(0));
      expect(transaction.targetMonth, equals(0));
      expect(transaction.targetYear, equals(0));
    });

    test('deve criar transação com todos os valores', () {
      final transaction = Transaction(
        id: 1,
        amountCents: 5000,
        type: TransactionType.expense,
        category: 'food',
        description: 'Almoço',
        humanDate: '2026-02-03',
        isRecurring: true,
        createdAt: 1738540800000,
        targetMonth: 2,
        targetYear: 2026,
      );

      expect(transaction.id, equals(1));
      expect(transaction.amountCents, equals(5000));
      expect(transaction.type, equals(TransactionType.expense));
      expect(transaction.category, equals('food'));
      expect(transaction.description, equals('Almoço'));
      expect(transaction.humanDate, equals('2026-02-03'));
      expect(transaction.isRecurring, isTrue);
      expect(transaction.createdAt, equals(1738540800000));
      expect(transaction.targetMonth, equals(2));
      expect(transaction.targetYear, equals(2026));
    });

    test('copyWith deve criar cópia com valores alterados', () {
      final original = Transaction(
        id: 1,
        amountCents: 1000,
        type: TransactionType.income,
        category: 'salary',
        description: 'Salário',
        humanDate: '2026-02-01',
        isRecurring: false,
        createdAt: 1738368000000,
        targetMonth: 2,
        targetYear: 2026,
      );

      final copy = original.copyWith(amountCents: 2000, description: 'Bônus');

      expect(copy.id, equals(1));
      expect(copy.amountCents, equals(2000));
      expect(copy.type, equals(TransactionType.income));
      expect(copy.category, equals('salary'));
      expect(copy.description, equals('Bônus'));
      expect(copy.humanDate, equals('2026-02-01'));
      expect(copy.isRecurring, isFalse);
      expect(copy.createdAt, equals(1738368000000));
      expect(copy.targetMonth, equals(2));
      expect(copy.targetYear, equals(2026));
    });

    test('igualdade deve funcionar corretamente para transações iguais', () {
      final t1 = Transaction(
        id: 1,
        amountCents: 1000,
        type: TransactionType.income,
        category: 'salary',
        description: 'Test',
        humanDate: '2026-02-03',
        isRecurring: false,
        createdAt: 1738540800000,
        targetMonth: 2,
        targetYear: 2026,
      );

      final t2 = Transaction(
        id: 1,
        amountCents: 1000,
        type: TransactionType.income,
        category: 'salary',
        description: 'Test',
        humanDate: '2026-02-03',
        isRecurring: false,
        createdAt: 1738540800000,
        targetMonth: 2,
        targetYear: 2026,
      );

      expect(t1, equals(t2));
      expect(t1.hashCode, equals(t2.hashCode));
    });

    test('igualdade deve retornar false para transações diferentes', () {
      final t1 = Transaction(
        id: 1,
        amountCents: 1000,
        type: TransactionType.income,
      );

      final t2 = Transaction(
        id: 2,
        amountCents: 1000,
        type: TransactionType.income,
      );

      expect(t1, isNot(equals(t2)));
    });
  });

  group('TransactionType', () {
    test('deve ter dois valores', () {
      expect(TransactionType.values.length, equals(2));
    });

    test('deve conter income e expense', () {
      expect(TransactionType.values, contains(TransactionType.income));
      expect(TransactionType.values, contains(TransactionType.expense));
    });
  });
}
