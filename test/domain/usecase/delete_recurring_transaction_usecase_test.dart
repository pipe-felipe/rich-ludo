import 'package:flutter_test/flutter_test.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/domain/usecase/delete_recurring_transaction_usecase.dart';
import '../../fakes/fake_transaction_repository.dart';

void main() {
  late FakeTransactionRepository fakeRepository;
  late DeleteRecurringTransactionUseCase useCase;

  setUp(() {
    fakeRepository = FakeTransactionRepository();
    useCase = DeleteRecurringTransactionUseCase(fakeRepository);
  });

  Transaction createRecurring({
    int id = 1,
    int targetMonth = 3,
    int targetYear = 2026,
    int? endMonth,
    int? endYear,
  }) {
    return Transaction(
      id: id,
      amountCents: 5000,
      type: TransactionType.expense,
      isRecurring: true,
      targetMonth: targetMonth,
      targetYear: targetYear,
      endMonth: endMonth,
      endYear: endYear,
    );
  }

  group('DeleteRecurringTransactionUseCase', () {
    group('allMonths', () {
      test('deve deletar a transação completamente', () async {
        final tx = createRecurring();
        fakeRepository.addTransaction(tx);

        final result = await useCase(
          transaction: tx,
          mode: RecurringDeleteMode.allMonths,
          currentMonth: 5,
          currentYear: 2026,
        );

        expect(result.isOk, isTrue);
        final remaining = await fakeRepository.getTransactions();
        expect(remaining.asOk.value, isEmpty);
      });
    });

    group('thisMonth', () {
      test('deve adicionar exclusão para o mês atual', () async {
        final tx = createRecurring();
        fakeRepository.addTransaction(tx);

        final result = await useCase(
          transaction: tx,
          mode: RecurringDeleteMode.thisMonth,
          currentMonth: 5,
          currentYear: 2026,
        );

        expect(result.isOk, isTrue);
        final exclusions = await fakeRepository.getExclusions();
        final exList = exclusions.asOk.value;
        expect(exList.length, equals(1));
        expect(exList[0].transactionId, equals(1));
        expect(exList[0].month, equals(5));
        expect(exList[0].year, equals(2026));
      });

      test(
        'deve deletar tudo quando é o único mês (start == end == current)',
        () async {
          final tx = createRecurring(
            targetMonth: 5,
            targetYear: 2026,
            endMonth: 5,
            endYear: 2026,
          );
          fakeRepository.addTransaction(tx);

          final result = await useCase(
            transaction: tx,
            mode: RecurringDeleteMode.thisMonth,
            currentMonth: 5,
            currentYear: 2026,
          );

          expect(result.isOk, isTrue);
          final remaining = await fakeRepository.getTransactions();
          expect(remaining.asOk.value, isEmpty);
        },
      );
    });

    group('thisAndPreviousMonths', () {
      test('deve atualizar targetMonth para o mês seguinte', () async {
        final tx = createRecurring(targetMonth: 3, targetYear: 2026);
        fakeRepository.addTransaction(tx);

        final result = await useCase(
          transaction: tx,
          mode: RecurringDeleteMode.thisAndPreviousMonths,
          currentMonth: 5,
          currentYear: 2026,
        );

        expect(result.isOk, isTrue);
        final remaining = await fakeRepository.getTransactions();
        final updated = remaining.asOk.value.first;
        expect(updated.targetMonth, equals(6));
        expect(updated.targetYear, equals(2026));
      });

      test('deve virar o ano quando mês atual é dezembro', () async {
        final tx = createRecurring(targetMonth: 10, targetYear: 2026);
        fakeRepository.addTransaction(tx);

        final result = await useCase(
          transaction: tx,
          mode: RecurringDeleteMode.thisAndPreviousMonths,
          currentMonth: 12,
          currentYear: 2026,
        );

        expect(result.isOk, isTrue);
        final remaining = await fakeRepository.getTransactions();
        final updated = remaining.asOk.value.first;
        expect(updated.targetMonth, equals(1));
        expect(updated.targetYear, equals(2027));
      });

      test(
        'deve deletar tudo quando próximo mês ultrapassa endMonth',
        () async {
          final tx = createRecurring(
            targetMonth: 3,
            targetYear: 2026,
            endMonth: 5,
            endYear: 2026,
          );
          fakeRepository.addTransaction(tx);

          final result = await useCase(
            transaction: tx,
            mode: RecurringDeleteMode.thisAndPreviousMonths,
            currentMonth: 5,
            currentYear: 2026,
          );

          expect(result.isOk, isTrue);
          final remaining = await fakeRepository.getTransactions();
          expect(remaining.asOk.value, isEmpty);
        },
      );
    });

    group('thisAndFutureMonths', () {
      test('deve definir endMonth como mês anterior', () async {
        final tx = createRecurring(targetMonth: 3, targetYear: 2026);
        fakeRepository.addTransaction(tx);

        final result = await useCase(
          transaction: tx,
          mode: RecurringDeleteMode.thisAndFutureMonths,
          currentMonth: 7,
          currentYear: 2026,
        );

        expect(result.isOk, isTrue);
        final remaining = await fakeRepository.getTransactions();
        final updated = remaining.asOk.value.first;
        expect(updated.endMonth, equals(6));
        expect(updated.endYear, equals(2026));
      });

      test('deve virar o ano quando mês atual é janeiro', () async {
        final tx = createRecurring(targetMonth: 10, targetYear: 2025);
        fakeRepository.addTransaction(tx);

        final result = await useCase(
          transaction: tx,
          mode: RecurringDeleteMode.thisAndFutureMonths,
          currentMonth: 1,
          currentYear: 2026,
        );

        expect(result.isOk, isTrue);
        final remaining = await fakeRepository.getTransactions();
        final updated = remaining.asOk.value.first;
        expect(updated.endMonth, equals(12));
        expect(updated.endYear, equals(2025));
      });

      test(
        'deve deletar tudo quando mês anterior é antes do targetMonth',
        () async {
          final tx = createRecurring(targetMonth: 5, targetYear: 2026);
          fakeRepository.addTransaction(tx);

          final result = await useCase(
            transaction: tx,
            mode: RecurringDeleteMode.thisAndFutureMonths,
            currentMonth: 5,
            currentYear: 2026,
          );

          expect(result.isOk, isTrue);
          final remaining = await fakeRepository.getTransactions();
          expect(remaining.asOk.value, isEmpty);
        },
      );
    });
  });
}
