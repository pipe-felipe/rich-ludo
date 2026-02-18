import 'package:flutter_test/flutter_test.dart';
import 'package:rich_ludo/domain/model/recurring_exclusion.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/domain/usecase/make_transaction_usecase.dart';

import '../../fakes/fake_transaction_repository.dart';

void main() {
  late FakeTransactionRepository repository;
  late MakeTransactionUseCase useCase;

  setUp(() {
    repository = FakeTransactionRepository();
    useCase = MakeTransactionUseCase(repository);
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

      final result = await useCase(transaction);

      expect(result.isOk, isTrue);
      final transactions = await repository.getTransactions();
      expect(transactions.asOk.value.length, equals(1));
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

      final result = await useCase(transaction);

      expect(result.isOk, isTrue);
      final transactions = await repository.getTransactions();
      expect(transactions.asOk.value.length, equals(1));
      expect(transactions.asOk.value.first.type, TransactionType.expense);
    });

    test('deve retornar Result.error quando repositório falha', () async {
      repository.shouldReturnError = true;

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

      final result = await useCase(transaction);

      expect(result.isError, isTrue);
    });
  });

  group('MakeTransactionUseCase - reativação de recorrente excluído', () {
    test(
      'deve remover exclusão ao adicionar item igual a recorrente excluído',
      () async {
        final recurring = Transaction(
          id: 10,
          amountCents: 9900,
          type: TransactionType.expense,
          category: 'recurring',
          description: 'Internet',
          isRecurring: true,
          targetMonth: 1,
          targetYear: 2026,
        );
        repository.addTransaction(recurring);
        await repository.addExclusion(
          const RecurringExclusion(transactionId: 10, month: 4, year: 2026),
        );

        final newTx = Transaction(
          amountCents: 9900,
          type: TransactionType.expense,
          category: 'recurring',
          description: 'Internet',
          isRecurring: false,
          targetMonth: 4,
          targetYear: 2026,
        );

        final result = await useCase(newTx);

        expect(result.isOk, isTrue);

        final exclusions = await repository.getExclusions();
        expect(exclusions.asOk.value, isEmpty);

        final transactions = await repository.getTransactions();
        expect(transactions.asOk.value.length, equals(1));
      },
    );

    test(
      'deve criar novo item quando categoria é diferente do recorrente excluído',
      () async {
        final recurring = Transaction(
          id: 10,
          amountCents: 9900,
          type: TransactionType.expense,
          category: 'recurring',
          description: 'Internet',
          isRecurring: true,
          targetMonth: 1,
          targetYear: 2026,
        );
        repository.addTransaction(recurring);
        await repository.addExclusion(
          const RecurringExclusion(transactionId: 10, month: 4, year: 2026),
        );

        final newTx = Transaction(
          amountCents: 9900,
          type: TransactionType.expense,
          category: 'food',
          description: 'Internet',
          isRecurring: false,
          targetMonth: 4,
          targetYear: 2026,
        );

        await useCase(newTx);

        final exclusions = await repository.getExclusions();
        expect(exclusions.asOk.value.length, equals(1));

        final transactions = await repository.getTransactions();
        expect(transactions.asOk.value.length, equals(2));
      },
    );

    test(
      'deve criar novo item quando valor é diferente do recorrente excluído',
      () async {
        final recurring = Transaction(
          id: 10,
          amountCents: 9900,
          type: TransactionType.expense,
          category: 'recurring',
          description: 'Internet',
          isRecurring: true,
          targetMonth: 1,
          targetYear: 2026,
        );
        repository.addTransaction(recurring);
        await repository.addExclusion(
          const RecurringExclusion(transactionId: 10, month: 4, year: 2026),
        );

        final newTx = Transaction(
          amountCents: 12000,
          type: TransactionType.expense,
          category: 'recurring',
          description: 'Internet',
          isRecurring: false,
          targetMonth: 4,
          targetYear: 2026,
        );

        await useCase(newTx);

        final exclusions = await repository.getExclusions();
        expect(exclusions.asOk.value.length, equals(1));

        final transactions = await repository.getTransactions();
        expect(transactions.asOk.value.length, equals(2));
      },
    );

    test(
      'deve criar novo item quando mês é diferente da exclusão',
      () async {
        final recurring = Transaction(
          id: 10,
          amountCents: 9900,
          type: TransactionType.expense,
          category: 'recurring',
          description: 'Internet',
          isRecurring: true,
          targetMonth: 1,
          targetYear: 2026,
        );
        repository.addTransaction(recurring);
        await repository.addExclusion(
          const RecurringExclusion(transactionId: 10, month: 4, year: 2026),
        );

        final newTx = Transaction(
          amountCents: 9900,
          type: TransactionType.expense,
          category: 'recurring',
          description: 'Internet',
          isRecurring: false,
          targetMonth: 5,
          targetYear: 2026,
        );

        await useCase(newTx);

        final exclusions = await repository.getExclusions();
        expect(exclusions.asOk.value.length, equals(1));

        final transactions = await repository.getTransactions();
        expect(transactions.asOk.value.length, equals(2));
      },
    );

    test(
      'deve criar novo item quando não existe exclusão para recorrente igual',
      () async {
        final recurring = Transaction(
          id: 10,
          amountCents: 9900,
          type: TransactionType.expense,
          category: 'recurring',
          description: 'Internet',
          isRecurring: true,
          targetMonth: 1,
          targetYear: 2026,
        );
        repository.addTransaction(recurring);

        final newTx = Transaction(
          amountCents: 9900,
          type: TransactionType.expense,
          category: 'recurring',
          description: 'Internet',
          isRecurring: false,
          targetMonth: 4,
          targetYear: 2026,
        );

        await useCase(newTx);

        final transactions = await repository.getTransactions();
        expect(transactions.asOk.value.length, equals(2));
      },
    );

    test(
      'deve criar novo item quando tipo é diferente do recorrente excluído',
      () async {
        final recurring = Transaction(
          id: 10,
          amountCents: 9900,
          type: TransactionType.expense,
          category: 'recurring',
          description: 'Internet',
          isRecurring: true,
          targetMonth: 1,
          targetYear: 2026,
        );
        repository.addTransaction(recurring);
        await repository.addExclusion(
          const RecurringExclusion(transactionId: 10, month: 4, year: 2026),
        );

        final newTx = Transaction(
          amountCents: 9900,
          type: TransactionType.income,
          category: 'recurring',
          description: 'Internet',
          isRecurring: false,
          targetMonth: 4,
          targetYear: 2026,
        );

        await useCase(newTx);

        final exclusions = await repository.getExclusions();
        expect(exclusions.asOk.value.length, equals(1));

        final transactions = await repository.getTransactions();
        expect(transactions.asOk.value.length, equals(2));
      },
    );
  });
}
