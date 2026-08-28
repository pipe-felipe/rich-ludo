import 'package:flutter_test/flutter_test.dart';
import 'package:rich_ludo/domain/model/recurring_exclusion.dart';
import 'package:rich_ludo/domain/model/recurring_scope.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/domain/usecase/update_recurring_transaction_usecase.dart';
import '../../fakes/fake_transaction_repository.dart';

void main() {
  late FakeTransactionRepository fakeRepository;
  late UpdateRecurringTransactionUseCase useCase;

  setUp(() {
    fakeRepository = FakeTransactionRepository();
    useCase = UpdateRecurringTransactionUseCase(fakeRepository);
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
      category: 'food',
      isRecurring: true,
      targetMonth: targetMonth,
      targetYear: targetYear,
      endMonth: endMonth,
      endYear: endYear,
    );
  }

  Transaction edit(Transaction original, {bool isRecurring = true}) {
    return original.copyWith(amountCents: 9900, isRecurring: isRecurring);
  }

  group('UpdateRecurringTransactionUseCase', () {
    group('allMonths', () {
      test('should write the edited values onto the stored row', () async {
        final tx = createRecurring();
        fakeRepository.addTransaction(tx);

        final result = await useCase(
          original: tx,
          edited: edit(tx),
          scope: RecurringScope.allMonths,
          currentMonth: 5,
          currentYear: 2026,
        );

        expect(result.isOk, isTrue);
        final transactions = await fakeRepository.getTransactions();
        expect(transactions.asOk.value, hasLength(1));
        expect(transactions.asOk.value.first.amountCents, equals(9900));
      });

      test(
        'should clear the exclusions when repetition is turned off',
        () async {
          final tx = createRecurring();
          fakeRepository.addTransaction(tx);
          fakeRepository.addExclusion(
            const RecurringExclusion(transactionId: 1, month: 4, year: 2026),
          );

          final result = await useCase(
            original: tx,
            edited: edit(tx, isRecurring: false),
            scope: RecurringScope.allMonths,
            currentMonth: 5,
            currentYear: 2026,
          );

          expect(result.isOk, isTrue);
          final exclusions = await fakeRepository.getExclusions();
          expect(exclusions.asOk.value, isEmpty);
          final transactions = await fakeRepository.getTransactions();
          expect(transactions.asOk.value.first.isRecurring, isFalse);
        },
      );
    });

    group('thisMonth', () {
      test(
        'should exclude the current month and insert a one-off copy',
        () async {
          final tx = createRecurring();
          fakeRepository.addTransaction(tx);

          final result = await useCase(
            original: tx,
            edited: edit(tx),
            scope: RecurringScope.thisMonth,
            currentMonth: 5,
            currentYear: 2026,
          );

          expect(result.isOk, isTrue);
          final exclusions = await fakeRepository.getExclusions();
          final exList = exclusions.asOk.value;
          expect(exList, hasLength(1));
          expect(exList[0].month, equals(5));
          expect(exList[0].year, equals(2026));
          final transactions = await fakeRepository.getTransactions();
          expect(transactions.asOk.value, hasLength(2));
          final copy = transactions.asOk.value[1];
          expect(copy.amountCents, equals(9900));
          expect(copy.isRecurring, isFalse);
          expect(copy.targetMonth, equals(5));
          expect(copy.targetYear, equals(2026));
          expect(copy.endMonth, isNull);
          expect(copy.endYear, isNull);
        },
      );

      test('should keep the original row untouched', () async {
        final tx = createRecurring();
        fakeRepository.addTransaction(tx);

        await useCase(
          original: tx,
          edited: edit(tx),
          scope: RecurringScope.thisMonth,
          currentMonth: 5,
          currentYear: 2026,
        );

        final transactions = await fakeRepository.getTransactions();
        final original = transactions.asOk.value.firstWhere(
          (stored) => stored.id == 1,
        );
        expect(original.amountCents, equals(5000));
        expect(original.targetMonth, equals(3));
        expect(original.isRecurring, isTrue);
      });

      test(
        'should update the row in place when the rule spans only this month',
        () async {
          final tx = createRecurring(
            targetMonth: 5,
            targetYear: 2026,
            endMonth: 5,
            endYear: 2026,
          );
          fakeRepository.addTransaction(tx);

          await useCase(
            original: tx,
            edited: edit(tx),
            scope: RecurringScope.thisMonth,
            currentMonth: 5,
            currentYear: 2026,
          );

          final transactions = await fakeRepository.getTransactions();
          expect(transactions.asOk.value, hasLength(1));
          expect(transactions.asOk.value.first.amountCents, equals(9900));
          final exclusions = await fakeRepository.getExclusions();
          expect(exclusions.asOk.value, isEmpty);
        },
      );
    });

    group('thisAndPreviousMonths', () {
      test('should move the original start past the current month', () async {
        final tx = createRecurring();
        fakeRepository.addTransaction(tx);

        await useCase(
          original: tx,
          edited: edit(tx),
          scope: RecurringScope.thisAndPreviousMonths,
          currentMonth: 5,
          currentYear: 2026,
        );

        final transactions = await fakeRepository.getTransactions();
        final original = transactions.asOk.value.firstWhere(
          (stored) => stored.id == 1,
        );
        expect(original.targetMonth, equals(6));
        expect(original.targetYear, equals(2026));
      });

      test(
        'should insert a recurring copy covering the original start through this month',
        () async {
          final tx = createRecurring();
          fakeRepository.addTransaction(tx);

          await useCase(
            original: tx,
            edited: edit(tx),
            scope: RecurringScope.thisAndPreviousMonths,
            currentMonth: 5,
            currentYear: 2026,
          );

          final transactions = await fakeRepository.getTransactions();
          expect(transactions.asOk.value, hasLength(2));
          final copy = transactions.asOk.value[1];
          expect(copy.amountCents, equals(9900));
          expect(copy.isRecurring, isTrue);
          expect(copy.targetMonth, equals(3));
          expect(copy.targetYear, equals(2026));
          expect(copy.endMonth, equals(5));
          expect(copy.endYear, equals(2026));
        },
      );

      test(
        'should update the row in place when nothing is left after this month',
        () async {
          final tx = createRecurring(endMonth: 5, endYear: 2026);
          fakeRepository.addTransaction(tx);

          await useCase(
            original: tx,
            edited: edit(tx),
            scope: RecurringScope.thisAndPreviousMonths,
            currentMonth: 5,
            currentYear: 2026,
          );

          final transactions = await fakeRepository.getTransactions();
          expect(transactions.asOk.value, hasLength(1));
          expect(transactions.asOk.value.first.amountCents, equals(9900));
          expect(transactions.asOk.value.first.targetMonth, equals(3));
        },
      );
    });

    group('thisAndFutureMonths', () {
      test(
        'should end the original at the previous month and insert a recurring copy',
        () async {
          final tx = createRecurring(endMonth: 12, endYear: 2026);
          fakeRepository.addTransaction(tx);

          await useCase(
            original: tx,
            edited: edit(tx),
            scope: RecurringScope.thisAndFutureMonths,
            currentMonth: 5,
            currentYear: 2026,
          );

          final transactions = await fakeRepository.getTransactions();
          final original = transactions.asOk.value.firstWhere(
            (stored) => stored.id == 1,
          );
          expect(original.endMonth, equals(4));
          expect(original.endYear, equals(2026));
          expect(transactions.asOk.value, hasLength(2));
          final copy = transactions.asOk.value[1];
          expect(copy.isRecurring, isTrue);
          expect(copy.targetMonth, equals(5));
          expect(copy.targetYear, equals(2026));
          expect(copy.endMonth, equals(12));
          expect(copy.endYear, equals(2026));
        },
      );

      test(
        'should insert a one-off copy when repetition is turned off',
        () async {
          final tx = createRecurring(endMonth: 12, endYear: 2026);
          fakeRepository.addTransaction(tx);

          await useCase(
            original: tx,
            edited: edit(tx, isRecurring: false),
            scope: RecurringScope.thisAndFutureMonths,
            currentMonth: 5,
            currentYear: 2026,
          );

          final transactions = await fakeRepository.getTransactions();
          expect(transactions.asOk.value, hasLength(2));
          final copy = transactions.asOk.value[1];
          expect(copy.isRecurring, isFalse);
          expect(copy.targetMonth, equals(5));
          expect(copy.endMonth, isNull);
          expect(copy.endYear, isNull);
        },
      );

      test(
        'should update the row in place when nothing is left before this month',
        () async {
          final tx = createRecurring(targetMonth: 5, targetYear: 2026);
          fakeRepository.addTransaction(tx);

          await useCase(
            original: tx,
            edited: edit(tx),
            scope: RecurringScope.thisAndFutureMonths,
            currentMonth: 5,
            currentYear: 2026,
          );

          final transactions = await fakeRepository.getTransactions();
          expect(transactions.asOk.value, hasLength(1));
          expect(transactions.asOk.value.first.amountCents, equals(9900));
          expect(transactions.asOk.value.first.endMonth, isNull);
        },
      );
    });

    group('errors', () {
      test('should return Result.error when the repository fails', () async {
        final tx = createRecurring();
        fakeRepository.addTransaction(tx);
        fakeRepository.shouldReturnError = true;

        final result = await useCase(
          original: tx,
          edited: edit(tx),
          scope: RecurringScope.allMonths,
          currentMonth: 5,
          currentYear: 2026,
        );

        expect(result.isError, isTrue);
      });
    });
  });
}
