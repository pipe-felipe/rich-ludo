import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/domain/repository/transaction_repository.dart';
import 'package:rich_ludo/domain/usecase/get_transactions_usecase.dart';
import 'package:rich_ludo/utils/result.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockRepository;
  late GetTransactionsUseCase useCase;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = GetTransactionsUseCase(mockRepository);
  });

  group('GetTransactionsUseCase', () {
    test('deve retornar Result.ok com transações do repositório', () async {
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
        Transaction(
          id: 2,
          amountCents: 500,
          type: TransactionType.expense,
          description: 'Almoço',
          createdAt: 1738540800000,
          targetMonth: 2,
          targetYear: 2026,
        ),
      ];

      when(
        () => mockRepository.getTransactions(),
      ).thenAnswer((_) async => Result.ok(transactions));

      final result = await useCase();

      expect(result.isOk, isTrue);
      expect(result.asOk.value.length, equals(2));
      expect(result.asOk.value[0].amountCents, equals(1000));
      expect(result.asOk.value[1].amountCents, equals(500));
      verify(() => mockRepository.getTransactions()).called(1);
    });

    test(
      'deve retornar Result.ok com lista vazia quando não há transações',
      () async {
        when(
          () => mockRepository.getTransactions(),
        ).thenAnswer((_) async => const Result.ok([]));

        final result = await useCase();

        expect(result.isOk, isTrue);
        expect(result.asOk.value, isEmpty);
        verify(() => mockRepository.getTransactions()).called(1);
      },
    );

    test('deve retornar Result.error quando repositório falha', () async {
      when(
        () => mockRepository.getTransactions(),
      ).thenAnswer((_) async => Result.error(Exception('Erro de conexão')));

      final result = await useCase();

      expect(result.isError, isTrue);
      verify(() => mockRepository.getTransactions()).called(1);
    });
  });
}
