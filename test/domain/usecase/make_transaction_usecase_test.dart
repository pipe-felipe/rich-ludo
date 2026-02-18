import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/domain/repository/transaction_repository.dart';
import 'package:rich_ludo/domain/usecase/make_transaction_usecase.dart';
import 'package:rich_ludo/utils/result.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class FakeTransaction extends Fake implements Transaction {}

void main() {
  late MockTransactionRepository mockRepository;
  late MakeTransactionUseCase useCase;

  setUpAll(() {
    registerFallbackValue(FakeTransaction());
  });

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = MakeTransactionUseCase(mockRepository);
  });

  group('MakeTransactionUseCase', () {
    test('deve criar transação e retornar Result.ok com ID', () async {
      final transaction = Transaction(
        amountCents: 1000,
        type: TransactionType.income,
        category: 'salary',
        description: 'Salário mensal',
        humanDate: '2026-02-03',
        isRecurring: true,
        createdAt: 1738368000000,
        targetMonth: 2,
        targetYear: 2026,
      );

      when(
        () => mockRepository.makeTransaction(any()),
      ).thenAnswer((_) async => const Result.ok(1));

      final result = await useCase(transaction);

      expect(result.isOk, isTrue);
      expect(result.asOk.value, equals(1));
      verify(() => mockRepository.makeTransaction(transaction)).called(1);
    });

    test('deve criar transação de despesa corretamente', () async {
      final transaction = Transaction(
        amountCents: 500,
        type: TransactionType.expense,
        category: 'food',
        description: 'Almoço',
        humanDate: '2026-02-03',
        isRecurring: false,
        createdAt: 1738540800000,
        targetMonth: 2,
        targetYear: 2026,
      );

      when(
        () => mockRepository.makeTransaction(any()),
      ).thenAnswer((_) async => const Result.ok(2));

      final result = await useCase(transaction);

      expect(result.isOk, isTrue);
      expect(result.asOk.value, equals(2));
      verify(() => mockRepository.makeTransaction(transaction)).called(1);
    });

    test('deve retornar Result.error quando repositório falha', () async {
      final transaction = Transaction(
        amountCents: 500,
        type: TransactionType.expense,
        category: 'food',
        description: 'Almoço',
        humanDate: '2026-02-03',
        isRecurring: false,
        createdAt: 1738540800000,
        targetMonth: 2,
        targetYear: 2026,
      );

      when(
        () => mockRepository.makeTransaction(any()),
      ).thenAnswer((_) async => Result.error(Exception('Erro de banco')));

      final result = await useCase(transaction);

      expect(result.isError, isTrue);
      verify(() => mockRepository.makeTransaction(transaction)).called(1);
    });
  });
}
