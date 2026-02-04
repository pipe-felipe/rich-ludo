import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/domain/repository/transaction_repository.dart';
import 'package:rich_ludo/domain/usecase/get_transactions_for_month_usecase.dart';
import 'package:rich_ludo/utils/result.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockRepository;
  late GetTransactionsForMonthUseCase useCase;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = GetTransactionsForMonthUseCase(mockRepository);
  });

  group('GetTransactionsForMonthUseCase', () {
    test('deve retornar transações do mês especificado', () async {
      // Fevereiro de 2026: 1738368000000 a 1740787200000
      const monthStart = 1738368000000;
      const monthEnd = 1740787200000;

      final transactions = [
        Transaction(
          id: 1,
          amountCents: 1000,
          type: TransactionType.income,
          description: 'Salário',
          createdAt: 1738540800000,
          targetMonth: 2,
          targetYear: 2026,
        ),
      ];

      when(() => mockRepository.getTransactionsForMonth(monthStart, monthEnd))
          .thenAnswer((_) async => Result.ok(transactions));

      final result = await useCase(monthStart, monthEnd);

      expect(result.isOk, isTrue);
      final value = result.asOk.value;
      expect(value.length, equals(1));
      expect(value[0].targetMonth, equals(2));
      expect(value[0].targetYear, equals(2026));
      verify(() => mockRepository.getTransactionsForMonth(monthStart, monthEnd)).called(1);
    });

    test('deve retornar lista vazia quando não há transações no mês', () async {
      const monthStart = 1738368000000;
      const monthEnd = 1740787200000;

      when(() => mockRepository.getTransactionsForMonth(monthStart, monthEnd))
          .thenAnswer((_) async => Result.ok(<Transaction>[]));

      final result = await useCase(monthStart, monthEnd);

      expect(result.isOk, isTrue);
      expect(result.asOk.value, isEmpty);
      verify(() => mockRepository.getTransactionsForMonth(monthStart, monthEnd)).called(1);
    });

    test('deve retornar erro quando repositório falha', () async {
      const monthStart = 1738368000000;
      const monthEnd = 1740787200000;

      when(() => mockRepository.getTransactionsForMonth(monthStart, monthEnd))
          .thenAnswer((_) async => Result.error(Exception('Database error')));

      final result = await useCase(monthStart, monthEnd);

      expect(result.isError, isTrue);
      verify(() => mockRepository.getTransactionsForMonth(monthStart, monthEnd)).called(1);
    });
  });
}
