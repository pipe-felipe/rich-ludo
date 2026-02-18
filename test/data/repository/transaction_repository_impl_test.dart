import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rich_ludo/data/repository/transaction_repository_impl.dart';
import 'package:rich_ludo/data/services/transaction_service.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/utils/result.dart';

class MockTransactionService extends Mock implements TransactionService {}

class FakeTransaction extends Fake implements Transaction {}

void main() {
  late MockTransactionService mockService;
  late TransactionRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(FakeTransaction());
  });

  setUp(() {
    mockService = MockTransactionService();
    repository = TransactionRepositoryImpl(service: mockService);
  });

  group('TransactionRepositoryImpl', () {
    group('getTransactions', () {
      test('deve retornar Result.ok com transações do Service', () async {
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

        when(
          () => mockService.getAllTransactions(),
        ).thenAnswer((_) async => Result.ok(transactions));

        final result = await repository.getTransactions();

        expect(result.isOk, isTrue);
        final value = result.asOk.value;
        expect(value.length, equals(1));
        expect(value[0].amountCents, equals(1000));
        verify(() => mockService.getAllTransactions()).called(1);
      });

      test('deve retornar Result.error quando Service falha', () async {
        when(
          () => mockService.getAllTransactions(),
        ).thenAnswer((_) async => Result.error(Exception('Database error')));

        final result = await repository.getTransactions();

        expect(result.isError, isTrue);
        verify(() => mockService.getAllTransactions()).called(1);
      });
    });

    group('getTransactionsForMonth', () {
      test('deve retornar transações do mês específico', () async {
        const monthStart = 1738368000000;
        const monthEnd = 1740787200000;

        final transactions = [
          Transaction(
            id: 1,
            amountCents: 500,
            type: TransactionType.expense,
            description: 'Almoço',
            createdAt: 1738540800000,
            targetMonth: 2,
            targetYear: 2026,
          ),
        ];

        when(
          () => mockService.getTransactionsForMonth(monthStart, monthEnd),
        ).thenAnswer((_) async => Result.ok(transactions));

        final result = await repository.getTransactionsForMonth(
          monthStart,
          monthEnd,
        );

        expect(result.isOk, isTrue);
        expect(result.asOk.value.length, equals(1));
        verify(
          () => mockService.getTransactionsForMonth(monthStart, monthEnd),
        ).called(1);
      });

      test('deve retornar erro quando Service falha', () async {
        const monthStart = 1738368000000;
        const monthEnd = 1740787200000;

        when(
          () => mockService.getTransactionsForMonth(monthStart, monthEnd),
        ).thenAnswer((_) async => Result.error(Exception('Database error')));

        final result = await repository.getTransactionsForMonth(
          monthStart,
          monthEnd,
        );

        expect(result.isError, isTrue);
        verify(
          () => mockService.getTransactionsForMonth(monthStart, monthEnd),
        ).called(1);
      });
    });

    group('makeTransaction', () {
      test('deve criar transação e retornar ID', () async {
        final transaction = Transaction(
          amountCents: 1000,
          type: TransactionType.income,
          category: 'salary',
          description: 'Salário',
          humanDate: '2026-02-03',
          isRecurring: false,
          createdAt: 1738540800000,
          targetMonth: 2,
          targetYear: 2026,
        );

        when(
          () => mockService.insertTransaction(any()),
        ).thenAnswer((_) async => Result.ok(1));

        final result = await repository.makeTransaction(transaction);

        expect(result.isOk, isTrue);
        expect(result.asOk.value, equals(1));
        verify(() => mockService.insertTransaction(transaction)).called(1);
      });

      test('deve retornar erro quando Service falha', () async {
        final transaction = Transaction(
          amountCents: 1000,
          type: TransactionType.income,
          targetMonth: 2,
          targetYear: 2026,
        );

        when(
          () => mockService.insertTransaction(any()),
        ).thenAnswer((_) async => Result.error(Exception('Insert failed')));

        final result = await repository.makeTransaction(transaction);

        expect(result.isError, isTrue);
        verify(() => mockService.insertTransaction(transaction)).called(1);
      });
    });

    group('deleteTransaction', () {
      test('deve deletar transação por ID', () async {
        const id = 42;

        when(
          () => mockService.deleteTransaction(id),
        ).thenAnswer((_) async => Result.ok(1));

        final result = await repository.deleteTransaction(id);

        expect(result.isOk, isTrue);
        expect(result.asOk.value, equals(1));
        verify(() => mockService.deleteTransaction(id)).called(1);
      });

      test('deve retornar 0 quando transação não existe', () async {
        const id = 999;

        when(
          () => mockService.deleteTransaction(id),
        ).thenAnswer((_) async => Result.ok(0));

        final result = await repository.deleteTransaction(id);

        expect(result.isOk, isTrue);
        expect(result.asOk.value, equals(0));
        verify(() => mockService.deleteTransaction(id)).called(1);
      });

      test('deve retornar erro quando Service falha', () async {
        const id = 42;

        when(
          () => mockService.deleteTransaction(id),
        ).thenAnswer((_) async => Result.error(Exception('Delete failed')));

        final result = await repository.deleteTransaction(id);

        expect(result.isError, isTrue);
        verify(() => mockService.deleteTransaction(id)).called(1);
      });
    });

    group('deleteAllTransactions', () {
      test('deve deletar todas as transações', () async {
        when(
          () => mockService.deleteAll(),
        ).thenAnswer((_) async => Result.ok(5));

        final result = await repository.deleteAllTransactions();

        expect(result.isOk, isTrue);
        expect(result.asOk.value, equals(5));
        verify(() => mockService.deleteAll()).called(1);
      });
    });

    group('insertTransactions', () {
      test('deve inserir múltiplas transações', () async {
        final transactions = [
          Transaction(
            amountCents: 1000,
            type: TransactionType.income,
            targetMonth: 2,
            targetYear: 2026,
          ),
          Transaction(
            amountCents: 500,
            type: TransactionType.expense,
            targetMonth: 2,
            targetYear: 2026,
          ),
        ];

        when(
          () => mockService.insertAll(any()),
        ).thenAnswer((_) async => Result.ok([1, 2]));

        final result = await repository.insertTransactions(transactions);

        expect(result.isOk, isTrue);
        expect(result.asOk.value, equals([1, 2]));
        verify(() => mockService.insertAll(transactions)).called(1);
      });
    });
  });
}
