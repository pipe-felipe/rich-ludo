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
      test('should return Result.ok with transactions from Service', () async {
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

      test('should return Result.error when Service fails', () async {
        when(
          () => mockService.getAllTransactions(),
        ).thenAnswer((_) async => Result.error(Exception('Database error')));

        final result = await repository.getTransactions();

        expect(result.isError, isTrue);
        verify(() => mockService.getAllTransactions()).called(1);
      });
    });

    group('getTransactionsByMonthYear and getNonRecurringBalance', () {
      test('should call getTransactionsByMonthYear and return list', () async {
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
          () => mockService.getTransactionsByMonthYear(2, 2026),
        ).thenAnswer((_) async => Result.ok(transactions));

        final result = await repository.getTransactionsByMonthYear(
          2,
          2026,
        );

        expect(result.isOk, isTrue);
        expect(result.asOk.value.length, equals(1));
        verify(
          () => mockService.getTransactionsByMonthYear(2, 2026),
        ).called(1);
      });

      test('should call getNonRecurringBalance and return int', () async {
        when(
          () => mockService.getNonRecurringBalance(2, 2026),
        ).thenAnswer((_) async => const Result.ok(1500));

        final result = await repository.getNonRecurringBalance(
          2,
          2026,
        );

        expect(result.isOk, isTrue);
        expect(result.asOk.value, equals(1500));
        verify(
          () => mockService.getNonRecurringBalance(2, 2026),
        ).called(1);
      });

      test('should return error when Service fails', () async {
        when(
          () => mockService.getTransactionsByMonthYear(2, 2026),
        ).thenAnswer((_) async => Result.error(Exception('Database error')));

        final result = await repository.getTransactionsByMonthYear(
          2,
          2026,
        );

        expect(result.isError, isTrue);
        verify(
          () => mockService.getTransactionsByMonthYear(2, 2026),
        ).called(1);
      });
    });

    group('makeTransaction', () {
      test('should create transaction and return ID', () async {
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

      test('should return error when Service fails', () async {
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
      test('should delete transaction by ID', () async {
        const id = 42;

        when(
          () => mockService.deleteTransaction(id),
        ).thenAnswer((_) async => Result.ok(1));

        final result = await repository.deleteTransaction(id);

        expect(result.isOk, isTrue);
        expect(result.asOk.value, equals(1));
        verify(() => mockService.deleteTransaction(id)).called(1);
      });

      test('should return 0 when transaction does not exist', () async {
        const id = 999;

        when(
          () => mockService.deleteTransaction(id),
        ).thenAnswer((_) async => Result.ok(0));

        final result = await repository.deleteTransaction(id);

        expect(result.isOk, isTrue);
        expect(result.asOk.value, equals(0));
        verify(() => mockService.deleteTransaction(id)).called(1);
      });

      test('should return error when Service fails', () async {
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
      test('should delete all transactions', () async {
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
      test('should insert multiple transactions', () async {
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
