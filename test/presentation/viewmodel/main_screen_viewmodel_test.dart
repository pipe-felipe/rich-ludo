import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rich_ludo/domain/model/recurring_exclusion.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/domain/model/category_total.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/domain/usecase/delete_recurring_transaction_usecase.dart';
import 'package:rich_ludo/domain/usecase/delete_transaction_usecase.dart';
import 'package:rich_ludo/domain/usecase/export_database_usecase.dart';
import 'package:rich_ludo/domain/usecase/get_exclusions_usecase.dart';
import 'package:rich_ludo/domain/usecase/import_database_usecase.dart';
import 'package:rich_ludo/presentation/viewmodel/main_screen_viewmodel.dart';
import 'package:rich_ludo/utils/result.dart';

import 'package:rich_ludo/domain/usecase/get_transactions_by_month_year_usecase.dart';
import 'package:rich_ludo/domain/usecase/get_non_recurring_balance_usecase.dart';

class MockGetTransactionsUseCase extends Mock
    implements GetTransactionsByMonthYearUseCase {}

class MockGetNonRecurringBalanceUseCase extends Mock
    implements GetNonRecurringBalanceUseCase {}

class MockDeleteTransactionUseCase extends Mock
    implements DeleteTransactionUseCase {}

class MockDeleteRecurringTransactionUseCase extends Mock
    implements DeleteRecurringTransactionUseCase {}

class MockGetExclusionsUseCase extends Mock implements GetExclusionsUseCase {}

class MockExportDatabaseUseCase extends Mock implements ExportDatabaseUseCase {}

class MockImportDatabaseUseCase extends Mock implements ImportDatabaseUseCase {}

void main() {
  late MockGetTransactionsUseCase mockGetTransactionsUseCase;
  late MockGetNonRecurringBalanceUseCase mockGetNonRecurringBalanceUseCase;
  late MockDeleteTransactionUseCase mockDeleteTransactionUseCase;
  late MockDeleteRecurringTransactionUseCase
  mockDeleteRecurringTransactionUseCase;
  late MockGetExclusionsUseCase mockGetExclusionsUseCase;
  late MockExportDatabaseUseCase mockExportDatabaseUseCase;
  late MockImportDatabaseUseCase mockImportDatabaseUseCase;

  setUp(() {
    mockGetTransactionsUseCase = MockGetTransactionsUseCase();
    mockGetNonRecurringBalanceUseCase = MockGetNonRecurringBalanceUseCase();
    mockDeleteTransactionUseCase = MockDeleteTransactionUseCase();
    mockDeleteRecurringTransactionUseCase =
        MockDeleteRecurringTransactionUseCase();
    mockGetExclusionsUseCase = MockGetExclusionsUseCase();
    mockExportDatabaseUseCase = MockExportDatabaseUseCase();
    mockImportDatabaseUseCase = MockImportDatabaseUseCase();
  });

  MainScreenViewModel createViewModel({
    List<Transaction> initialTransactions = const [],
    List<RecurringExclusion> initialExclusions = const [],
    List<Transaction> Function(int month, int year)? transactionsForMonth,
    Future<Result<List<Transaction>>> Function(int month, int year)?
    transactionsLoader,
  }) {
    when(
      () => mockGetTransactionsUseCase(
        month: any(named: 'month'),
        year: any(named: 'year'),
      ),
    ).thenAnswer((invocation) {
      final month = invocation.namedArguments[#month] as int;
      final year = invocation.namedArguments[#year] as int;
      if (transactionsLoader != null) {
        return transactionsLoader(month, year);
      }
      final transactions =
          transactionsForMonth?.call(month, year) ?? initialTransactions;
      return Future.value(Result.ok(transactions));
    });
    when(
      () => mockGetNonRecurringBalanceUseCase(
        upToMonth: any(named: 'upToMonth'),
        upToYear: any(named: 'upToYear'),
      ),
    ).thenAnswer((_) async => const Result.ok(0));
    when(
      () => mockGetExclusionsUseCase(),
    ).thenAnswer((_) async => Result.ok(initialExclusions));

    return MainScreenViewModel(
      getTransactionsUseCase: mockGetTransactionsUseCase,
      getNonRecurringBalanceUseCase: mockGetNonRecurringBalanceUseCase,
      deleteTransactionUseCase: mockDeleteTransactionUseCase,
      deleteRecurringTransactionUseCase: mockDeleteRecurringTransactionUseCase,
      getExclusionsUseCase: mockGetExclusionsUseCase,
      exportDatabaseUseCase: mockExportDatabaseUseCase,
      importDatabaseUseCase: mockImportDatabaseUseCase,
    );
  }

  Future<void> waitForLoad(MainScreenViewModel viewModel) async {
    while (viewModel.load.running) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  group('MainScreenViewModel', () {
    group('Initial State', () {
      test('should start with an empty list of items', () async {
        final viewModel = createViewModel();

        // Wait for the Command to complete
        await viewModel.load.execute();

        expect(viewModel.items, isEmpty);

        viewModel.dispose();
      });

      test('should start with zero totals', () async {
        final viewModel = createViewModel();

        await viewModel.load.execute();

        expect(viewModel.totalIncomeText, equals('R\$ 0.00'));
        expect(viewModel.totalExpenseText, equals('R\$ 0.00'));

        viewModel.dispose();
      });

      test('should start with current month and year', () {
        final viewModel = createViewModel();
        final now = DateTime.now();

        expect(viewModel.currentMonth, equals(now.month));
        expect(viewModel.currentYear, equals(now.year));

        viewModel.dispose();
      });
    });

    group('Command load', () {
      test('should have running state while loading', () async {
        final viewModel = createViewModel();

        final future = viewModel.load.execute();

        expect(viewModel.load.running, isTrue);

        await future;

        expect(viewModel.load.running, isFalse);
        expect(viewModel.load.completed, isTrue);

        viewModel.dispose();
      });

      test('should have error state when failed', () async {
        when(
          () => mockGetTransactionsUseCase(
            month: any(named: 'month'),
            year: any(named: 'year'),
          ),
        ).thenAnswer((_) async => Result.error(Exception('Database error')));
        when(
          () => mockGetNonRecurringBalanceUseCase(
            upToMonth: any(named: 'upToMonth'),
            upToYear: any(named: 'upToYear'),
          ),
        ).thenAnswer((_) async => const Result.ok(0));
        when(
          () => mockGetExclusionsUseCase(),
        ).thenAnswer((_) async => const Result.ok(<RecurringExclusion>[]));

        final viewModel = MainScreenViewModel(
          getTransactionsUseCase: mockGetTransactionsUseCase,
          getNonRecurringBalanceUseCase: mockGetNonRecurringBalanceUseCase,
          deleteTransactionUseCase: mockDeleteTransactionUseCase,
          deleteRecurringTransactionUseCase:
              mockDeleteRecurringTransactionUseCase,
          getExclusionsUseCase: mockGetExclusionsUseCase,
          exportDatabaseUseCase: mockExportDatabaseUseCase,
          importDatabaseUseCase: mockImportDatabaseUseCase,
        );

        await viewModel.load.execute();

        expect(viewModel.load.error, isTrue);

        viewModel.dispose();
      });
    });

    group('Month Navigation', () {
      test('goToNextMonth should advance the month', () async {
        final viewModel = createViewModel();
        await viewModel.load.execute();

        final initialMonth = viewModel.currentMonth;
        final initialYear = viewModel.currentYear;

        viewModel.goToNextMonth();

        if (initialMonth == 12) {
          expect(viewModel.currentMonth, equals(1));
          expect(viewModel.currentYear, equals(initialYear + 1));
        } else {
          expect(viewModel.currentMonth, equals(initialMonth + 1));
          expect(viewModel.currentYear, equals(initialYear));
        }

        viewModel.dispose();
      });

      test('goToPreviousMonth should go back a month', () async {
        final viewModel = createViewModel();
        await viewModel.load.execute();

        final initialMonth = viewModel.currentMonth;
        final initialYear = viewModel.currentYear;

        viewModel.goToPreviousMonth();

        if (initialMonth == 1) {
          expect(viewModel.currentMonth, equals(12));
          expect(viewModel.currentYear, equals(initialYear - 1));
        } else {
          expect(viewModel.currentMonth, equals(initialMonth - 1));
          expect(viewModel.currentYear, equals(initialYear));
        }

        viewModel.dispose();
      });

      test('goToNextMonth should roll over the year when December', () async {
        final viewModel = createViewModel();
        await viewModel.load.execute();

        // Navigate to December
        while (viewModel.currentMonth != 12) {
          viewModel.goToNextMonth();
        }

        final yearBefore = viewModel.currentYear;
        viewModel.goToNextMonth();

        expect(viewModel.currentMonth, equals(1));
        expect(viewModel.currentYear, equals(yearBefore + 1));

        viewModel.dispose();
      });

      test(
        'goToPreviousMonth should roll over the year when January',
        () async {
          final viewModel = createViewModel();
          await viewModel.load.execute();

          // Navigate to January
          while (viewModel.currentMonth != 1) {
            viewModel.goToPreviousMonth();
          }

          final yearBefore = viewModel.currentYear;
          viewModel.goToPreviousMonth();

          expect(viewModel.currentMonth, equals(12));
          expect(viewModel.currentYear, equals(yearBefore - 1));

          viewModel.dispose();
        },
      );

      test('goToCurrentMonth should return to current month', () async {
        final viewModel = createViewModel();
        await viewModel.load.execute();

        final now = DateTime.now();

        // Navigate away
        viewModel.goToNextMonth();
        viewModel.goToNextMonth();
        viewModel.goToNextMonth();

        viewModel.goToCurrentMonth();

        expect(viewModel.currentMonth, equals(now.month));
        expect(viewModel.currentYear, equals(now.year));

        viewModel.dispose();
      });

      test(
        'should recalculate selected month totals and reuse the cache',
        () async {
          final now = DateTime.now();
          final nextMonth = DateTime(now.year, now.month + 1);
          final currentMonthTransactions = [
            Transaction(
              id: 1,
              amountCents: 10000,
              type: TransactionType.income,
              targetMonth: now.month,
              targetYear: now.year,
            ),
            Transaction(
              id: 2,
              amountCents: 2500,
              type: TransactionType.expense,
              targetMonth: now.month,
              targetYear: now.year,
            ),
            Transaction(
              id: 5,
              amountCents: 99999,
              type: TransactionType.income,
              targetMonth: nextMonth.month,
              targetYear: nextMonth.year,
            ),
            Transaction(
              id: 6,
              amountCents: 88888,
              type: TransactionType.expense,
              targetMonth: nextMonth.month,
              targetYear: nextMonth.year,
            ),
          ];
          final nextMonthTransactions = [
            Transaction(
              id: 3,
              amountCents: 40000,
              type: TransactionType.income,
              targetMonth: nextMonth.month,
              targetYear: nextMonth.year,
            ),
            Transaction(
              id: 4,
              amountCents: 7000,
              type: TransactionType.expense,
              targetMonth: nextMonth.month,
              targetYear: nextMonth.year,
            ),
          ];

          final viewModel = createViewModel(
            transactionsForMonth: (month, year) {
              if (month == now.month && year == now.year) {
                return currentMonthTransactions;
              }
              if (month == nextMonth.month && year == nextMonth.year) {
                return nextMonthTransactions;
              }
              return const [];
            },
          );
          await waitForLoad(viewModel);

          expect(viewModel.totalIncomeCents, equals(10000));
          expect(viewModel.totalExpenseCents, equals(2500));
          expect(viewModel.items, hasLength(2));

          viewModel.goToNextMonth();
          await waitForLoad(viewModel);

          expect(viewModel.totalIncomeCents, equals(40000));
          expect(viewModel.totalExpenseCents, equals(7000));
          expect(viewModel.items, hasLength(2));

          viewModel.goToPreviousMonth();
          await waitForLoad(viewModel);

          expect(viewModel.totalIncomeCents, equals(10000));
          expect(viewModel.totalExpenseCents, equals(2500));
          verify(
            () => mockGetTransactionsUseCase(month: now.month, year: now.year),
          ).called(1);
          verify(
            () => mockGetTransactionsUseCase(
              month: nextMonth.month,
              year: nextMonth.year,
            ),
          ).called(1);

          viewModel.dispose();
        },
      );
    });

    group('Transactions Update', () {
      test('should update items when load executes successfully', () async {
        final now = DateTime.now();

        final transactions = [
          Transaction(
            id: 1,
            amountCents: 1000,
            type: TransactionType.income,
            description: 'Salary',
            createdAt: DateTime(now.year, now.month, 1).millisecondsSinceEpoch,
            targetMonth: now.month,
            targetYear: now.year,
          ),
        ];

        final viewModel = createViewModel(initialTransactions: transactions);

        await viewModel.load.execute();

        expect(viewModel.items.length, equals(1));
        expect(viewModel.items[0].amountCents, equals(1000));

        viewModel.dispose();
      });

      test('should calculate total income correctly', () async {
        final now = DateTime.now();

        final transactions = [
          Transaction(
            id: 1,
            amountCents: 10000, // R$ 100.00
            type: TransactionType.income,
            description: 'Salary',
            targetMonth: now.month,
            targetYear: now.year,
          ),
          Transaction(
            id: 2,
            amountCents: 5000, // R$ 50.00
            type: TransactionType.income,
            description: 'Bonus',
            targetMonth: now.month,
            targetYear: now.year,
          ),
        ];

        final viewModel = createViewModel(initialTransactions: transactions);

        await viewModel.load.execute();

        expect(viewModel.totalIncomeText, equals('R\$ 150.00'));

        viewModel.dispose();
      });

      test('should calculate total expenses correctly', () async {
        final now = DateTime.now();

        final transactions = [
          Transaction(
            id: 1,
            amountCents: 3050, // R$ 30.50
            type: TransactionType.expense,
            description: 'Lunch',
            targetMonth: now.month,
            targetYear: now.year,
          ),
          Transaction(
            id: 2,
            amountCents: 2000, // R$ 20.00
            type: TransactionType.expense,
            description: 'Transporte',
            targetMonth: now.month,
            targetYear: now.year,
          ),
        ];

        final viewModel = createViewModel(initialTransactions: transactions);

        await viewModel.load.execute();

        expect(viewModel.totalExpenseText, equals('R\$ 50.50'));

        viewModel.dispose();
      });
    });

    group('Delete transaction', () {
      test('should call delete use case via Command', () async {
        when(
          () => mockDeleteTransactionUseCase(any()),
        ).thenAnswer((_) async => Result.ok(1));

        final viewModel = createViewModel();
        await viewModel.load.execute();

        await viewModel.deleteTransaction.execute(42);

        verify(() => mockDeleteTransactionUseCase(42)).called(1);

        viewModel.dispose();
      });

      test(
        'deleteTransaction Command should have running state during execution',
        () async {
          when(
            () => mockDeleteTransactionUseCase(any()),
          ).thenAnswer((_) async => Result.ok(1));

          final viewModel = createViewModel();
          await viewModel.load.execute();

          final future = viewModel.deleteTransaction.execute(42);

          expect(viewModel.deleteTransaction.running, isTrue);

          await future;

          expect(viewModel.deleteTransaction.running, isFalse);
          expect(viewModel.deleteTransaction.completed, isTrue);

          viewModel.dispose();
        },
      );
    });

    group('Export database', () {
      test('should call export use case via Command', () async {
        when(
          () => mockExportDatabaseUseCase(),
        ).thenAnswer((_) async => Result.ok('/path/to/backup.ludo'));

        final viewModel = createViewModel();
        await viewModel.load.execute();

        await viewModel.exportDatabase.execute();

        verify(() => mockExportDatabaseUseCase()).called(1);

        viewModel.dispose();
      });

      test(
        'exportDatabase Command should have running state during execution',
        () async {
          when(
            () => mockExportDatabaseUseCase(),
          ).thenAnswer((_) async => Result.ok('/path/to/backup.ludo'));

          final viewModel = createViewModel();
          await viewModel.load.execute();

          final future = viewModel.exportDatabase.execute();

          expect(viewModel.exportDatabase.running, isTrue);

          await future;

          expect(viewModel.exportDatabase.running, isFalse);
          expect(viewModel.exportDatabase.completed, isTrue);

          viewModel.dispose();
        },
      );

      test(
        'exportDatabase Command should have error state when failed',
        () async {
          when(() => mockExportDatabaseUseCase()).thenAnswer(
            (_) async => Result.error(Exception('Error exporting database')),
          );

          final viewModel = createViewModel();
          await viewModel.load.execute();

          await viewModel.exportDatabase.execute();

          expect(viewModel.exportDatabase.error, isTrue);

          viewModel.dispose();
        },
      );

      test('exportDatabase Command should return exported file path', () async {
        const expectedPath = '/storage/emulated/0/Documents/backup.ludo';

        when(
          () => mockExportDatabaseUseCase(),
        ).thenAnswer((_) async => Result.ok(expectedPath));

        final viewModel = createViewModel();
        await viewModel.load.execute();

        await viewModel.exportDatabase.execute();

        expect(viewModel.exportDatabase.result?.isOk, isTrue);
        expect(
          viewModel.exportDatabase.result?.asOk.value,
          equals(expectedPath),
        );

        viewModel.dispose();
      });
    });

    group('Current month transactions filter', () {
      test('should show only current month transactions', () async {
        final now = DateTime.now();
        final nextMonth = now.month == 12 ? 1 : now.month + 1;
        final nextMonthYear = now.month == 12 ? now.year + 1 : now.year;

        final transactions = [
          Transaction(
            id: 1,
            amountCents: 5000,
            type: TransactionType.expense,
            description: 'Current month transaction',
            isRecurring: false,
            targetMonth: now.month,
            targetYear: now.year,
          ),
          Transaction(
            id: 2,
            amountCents: 3000,
            type: TransactionType.expense,
            description: 'Next month transaction',
            isRecurring: false,
            targetMonth: nextMonth,
            targetYear: nextMonthYear,
          ),
        ];

        final viewModel = createViewModel(initialTransactions: transactions);

        await viewModel.load.execute();

        expect(viewModel.items.length, equals(1));
        expect(
          viewModel.items[0].description,
          equals('Current month transaction'),
        );

        viewModel.dispose();
      });

      test(
        'should apply recurring transactions and exclusions to the selected month',
        () async {
          final now = DateTime.now();
          final nextMonth = DateTime(now.year, now.month + 1);
          final recurringIncome = Transaction(
            id: 10,
            amountCents: 12000,
            type: TransactionType.income,
            isRecurring: true,
            targetMonth: now.month == 1 ? 12 : now.month - 1,
            targetYear: now.month == 1 ? now.year - 1 : now.year,
          );
          final recurringExpense = Transaction(
            id: 11,
            amountCents: 4000,
            type: TransactionType.expense,
            isRecurring: true,
            targetMonth: recurringIncome.targetMonth,
            targetYear: recurringIncome.targetYear,
          );

          final viewModel = createViewModel(
            initialExclusions: [
              RecurringExclusion(
                transactionId: recurringExpense.id,
                month: now.month,
                year: now.year,
              ),
            ],
            transactionsForMonth: (month, year) {
              if (month == now.month && year == now.year ||
                  month == nextMonth.month && year == nextMonth.year) {
                return [recurringIncome, recurringExpense];
              }
              return const [];
            },
          );
          await waitForLoad(viewModel);

          expect(viewModel.totalIncomeCents, equals(12000));
          expect(viewModel.totalExpenseCents, isZero);

          viewModel.goToNextMonth();
          await waitForLoad(viewModel);

          expect(viewModel.totalIncomeCents, equals(12000));
          expect(viewModel.totalExpenseCents, equals(4000));

          viewModel.dispose();
        },
      );
    });

    group('Selected month summary', () {
      test('should calculate totals from selected month items only', () async {
        final selectedDate = DateTime.now();
        final otherMonth = DateTime(selectedDate.year, selectedDate.month - 1);
        final transactions = [
          Transaction(
            id: 1,
            amountCents: 12500,
            type: TransactionType.income,
            description: 'Selected month income',
            targetMonth: selectedDate.month,
            targetYear: selectedDate.year,
          ),
          Transaction(
            id: 2,
            amountCents: 4500,
            type: TransactionType.expense,
            description: 'Selected month expense',
            targetMonth: selectedDate.month,
            targetYear: selectedDate.year,
          ),
          Transaction(
            id: 3,
            amountCents: 99999,
            type: TransactionType.income,
            description: 'Other month income',
            targetMonth: otherMonth.month,
            targetYear: otherMonth.year,
          ),
          Transaction(
            id: 4,
            amountCents: 88888,
            type: TransactionType.expense,
            description: 'Other month expense',
            targetMonth: otherMonth.month,
            targetYear: otherMonth.year,
          ),
        ];

        final viewModel = createViewModel(initialTransactions: transactions);
        await waitForLoad(viewModel);

        expect(
          viewModel.items.map((transaction) => transaction.description),
          containsAll(<String?>[
            'Selected month income',
            'Selected month expense',
          ]),
        );
        expect(viewModel.items, hasLength(2));
        expect(viewModel.totalIncomeCents, equals(12500));
        expect(viewModel.totalExpenseCents, equals(4500));
        expect(viewModel.totalIncomeText, equals('R\$ 125.00'));
        expect(viewModel.totalExpenseText, equals('R\$ 45.00'));

        viewModel.dispose();
      });

      test(
        'should exclude future recurring transactions from the list',
        () async {
          final selectedDate = DateTime.now();
          final futureDate = DateTime(
            selectedDate.year,
            selectedDate.month + 1,
          );
          final futureRecurring = Transaction(
            id: 20,
            amountCents: 7000,
            type: TransactionType.income,
            description: 'Future recurring income',
            isRecurring: true,
            targetMonth: futureDate.month,
            targetYear: futureDate.year,
          );

          final viewModel = createViewModel(
            transactionsForMonth: (_, _) => [futureRecurring],
          );
          await waitForLoad(viewModel);

          expect(viewModel.items, isEmpty);
          expect(viewModel.totalIncomeCents, isZero);

          viewModel.goToNextMonth();
          await waitForLoad(viewModel);

          expect(viewModel.items, hasLength(1));
          expect(viewModel.totalIncomeCents, equals(7000));

          viewModel.dispose();
        },
      );

      test(
        'should apply recurring start and end months while navigating',
        () async {
          final selectedDate = DateTime.now();
          final nextDate = DateTime(selectedDate.year, selectedDate.month + 1);
          final afterEndDate = DateTime(
            selectedDate.year,
            selectedDate.month + 2,
          );
          final recurringExpense = Transaction(
            id: 21,
            amountCents: 3200,
            type: TransactionType.expense,
            description: 'Bounded recurring expense',
            isRecurring: true,
            targetMonth: selectedDate.month,
            targetYear: selectedDate.year,
            endMonth: nextDate.month,
            endYear: nextDate.year,
          );

          final viewModel = createViewModel(
            transactionsForMonth: (_, _) => [recurringExpense],
          );
          await waitForLoad(viewModel);

          viewModel.goToPreviousMonth();
          await waitForLoad(viewModel);
          expect(viewModel.items, isEmpty);

          viewModel.goToNextMonth();
          await waitForLoad(viewModel);
          expect(viewModel.items, hasLength(1));

          viewModel.goToNextMonth();
          await waitForLoad(viewModel);
          expect(viewModel.items, hasLength(1));
          expect(viewModel.totalExpenseCents, equals(3200));

          viewModel.goToNextMonth();
          await waitForLoad(viewModel);
          expect(viewModel.currentMonth, equals(afterEndDate.month));
          expect(viewModel.currentYear, equals(afterEndDate.year));
          expect(viewModel.items, isEmpty);
          expect(viewModel.totalExpenseCents, isZero);

          viewModel.dispose();
        },
      );
    });

    group('Recurring exclusions', () {
      test('should affect only the excluded selected month', () async {
        final selectedDate = DateTime.now();
        final nextDate = DateTime(selectedDate.year, selectedDate.month + 1);
        final recurringExpense = Transaction(
          id: 30,
          amountCents: 6100,
          type: TransactionType.expense,
          description: 'Recurring expense with exclusion',
          isRecurring: true,
          targetMonth: selectedDate.month - 1 == 0
              ? 12
              : selectedDate.month - 1,
          targetYear: selectedDate.month == 1
              ? selectedDate.year - 1
              : selectedDate.year,
        );

        final viewModel = createViewModel(
          initialExclusions: [
            RecurringExclusion(
              transactionId: recurringExpense.id,
              month: selectedDate.month,
              year: selectedDate.year,
            ),
          ],
          transactionsForMonth: (_, _) => [recurringExpense],
        );
        await waitForLoad(viewModel);

        expect(viewModel.items, isEmpty);
        expect(viewModel.totalExpenseCents, isZero);

        viewModel.goToNextMonth();
        await waitForLoad(viewModel);

        expect(viewModel.items, hasLength(1));
        expect(viewModel.totalExpenseCents, equals(6100));

        expect(viewModel.currentMonth, equals(nextDate.month));
        expect(viewModel.currentYear, equals(nextDate.year));
        viewModel.dispose();
      });
    });

    group('Expenses by category', () {
      test(
        'should group expenses by category for the selected month',
        () async {
          final selectedDate = DateTime.now();
          final transactions = [
            Transaction(
              id: 1,
              amountCents: 1000,
              type: TransactionType.expense,
              category: 'food',
              targetMonth: selectedDate.month,
              targetYear: selectedDate.year,
            ),
            Transaction(
              id: 2,
              amountCents: 500,
              type: TransactionType.expense,
              category: 'food',
              targetMonth: selectedDate.month,
              targetYear: selectedDate.year,
            ),
            Transaction(
              id: 3,
              amountCents: 700,
              type: TransactionType.expense,
              category: 'transport',
              targetMonth: selectedDate.month,
              targetYear: selectedDate.year,
            ),
          ];

          final viewModel = createViewModel(initialTransactions: transactions);
          await waitForLoad(viewModel);

          expect(viewModel.expenseByCategory, hasLength(2));
          expect(
            viewModel.expenseByCategory,
            contains(const CategoryTotal(category: 'food', amountCents: 1500)),
          );

          viewModel.dispose();
        },
      );

      test('should ignore income when grouping', () async {
        final selectedDate = DateTime.now();
        final transactions = [
          Transaction(
            id: 1,
            amountCents: 9000,
            type: TransactionType.income,
            category: 'salary',
            targetMonth: selectedDate.month,
            targetYear: selectedDate.year,
          ),
          Transaction(
            id: 2,
            amountCents: 300,
            type: TransactionType.expense,
            category: 'food',
            targetMonth: selectedDate.month,
            targetYear: selectedDate.year,
          ),
        ];

        final viewModel = createViewModel(initialTransactions: transactions);
        await waitForLoad(viewModel);

        expect(
          viewModel.expenseByCategory.single,
          equals(const CategoryTotal(category: 'food', amountCents: 300)),
        );

        viewModel.dispose();
      });

      test(
        'should group expenses without a category under a null key',
        () async {
          final selectedDate = DateTime.now();
          final transactions = [
            Transaction(
              id: 1,
              amountCents: 100,
              type: TransactionType.expense,
              targetMonth: selectedDate.month,
              targetYear: selectedDate.year,
            ),
            Transaction(
              id: 2,
              amountCents: 250,
              type: TransactionType.expense,
              targetMonth: selectedDate.month,
              targetYear: selectedDate.year,
            ),
          ];

          final viewModel = createViewModel(initialTransactions: transactions);
          await waitForLoad(viewModel);

          expect(
            viewModel.expenseByCategory.single,
            equals(const CategoryTotal(category: null, amountCents: 350)),
          );

          viewModel.dispose();
        },
      );

      test('should sort categories by amount descending', () async {
        final selectedDate = DateTime.now();
        final transactions = [
          Transaction(
            id: 1,
            amountCents: 100,
            type: TransactionType.expense,
            category: 'food',
            targetMonth: selectedDate.month,
            targetYear: selectedDate.year,
          ),
          Transaction(
            id: 2,
            amountCents: 900,
            type: TransactionType.expense,
            category: 'transport',
            targetMonth: selectedDate.month,
            targetYear: selectedDate.year,
          ),
          Transaction(
            id: 3,
            amountCents: 400,
            type: TransactionType.expense,
            category: 'gift',
            targetMonth: selectedDate.month,
            targetYear: selectedDate.year,
          ),
        ];

        final viewModel = createViewModel(initialTransactions: transactions);
        await waitForLoad(viewModel);

        expect(
          viewModel.expenseByCategory.map((total) => total.category).toList(),
          equals(['transport', 'gift', 'food']),
        );

        viewModel.dispose();
      });

      test('should be empty when the month has no expenses', () async {
        final selectedDate = DateTime.now();
        final transactions = [
          Transaction(
            id: 1,
            amountCents: 5000,
            type: TransactionType.income,
            category: 'salary',
            targetMonth: selectedDate.month,
            targetYear: selectedDate.year,
          ),
        ];

        final viewModel = createViewModel(initialTransactions: transactions);
        await waitForLoad(viewModel);

        expect(viewModel.expenseByCategory, isEmpty);

        viewModel.dispose();
      });

      test(
        'should clear the grouping when navigating to another month',
        () async {
          final selectedDate = DateTime.now();
          final transactions = [
            Transaction(
              id: 1,
              amountCents: 800,
              type: TransactionType.expense,
              category: 'food',
              targetMonth: selectedDate.month,
              targetYear: selectedDate.year,
            ),
          ];

          final viewModel = createViewModel(initialTransactions: transactions);
          await waitForLoad(viewModel);

          expect(viewModel.expenseByCategory, isNotEmpty);

          viewModel.goToNextMonth();

          expect(viewModel.expenseByCategory, isEmpty);

          viewModel.dispose();
        },
      );
    });

    group('Navigation race', () {
      test(
        'should keep the final selected month after a delayed load',
        () async {
          final selectedDate = DateTime.now();
          final nextDate = DateTime(selectedDate.year, selectedDate.month + 1);
          final firstLoad = Completer<Result<List<Transaction>>>();
          var isInitialRequest = true;

          final viewModel = createViewModel(
            transactionsLoader: (month, year) {
              if (isInitialRequest &&
                  month == selectedDate.month &&
                  year == selectedDate.year) {
                isInitialRequest = false;
                return firstLoad.future;
              }
              final isFinalMonth =
                  month == nextDate.month && year == nextDate.year;
              return Future.value(
                Result.ok([
                  Transaction(
                    id: isFinalMonth ? 32 : 31,
                    amountCents: isFinalMonth ? 8200 : 1100,
                    type: TransactionType.income,
                    description: isFinalMonth
                        ? 'Final month income'
                        : 'Stale month income',
                    targetMonth: month,
                    targetYear: year,
                  ),
                ]),
              );
            },
          );
          expect(viewModel.load.running, isTrue);

          viewModel.goToNextMonth();
          expect(viewModel.totalIncomeCents, isZero);
          expect(viewModel.totalExpenseCents, isZero);
          expect(viewModel.totalIncomeText, equals('R\$ 0.00'));

          firstLoad.complete(
            Result.ok([
              Transaction(
                id: 31,
                amountCents: 1100,
                type: TransactionType.income,
                description: 'Stale month income',
                targetMonth: selectedDate.month,
                targetYear: selectedDate.year,
              ),
            ]),
          );
          await waitForLoad(viewModel);

          expect(viewModel.currentMonth, equals(nextDate.month));
          expect(viewModel.currentYear, equals(nextDate.year));
          expect(
            viewModel.items.single.description,
            equals('Final month income'),
          );
          expect(viewModel.totalIncomeCents, equals(8200));
          expect(viewModel.totalExpenseCents, isZero);

          viewModel.dispose();
        },
      );
    });
  });
}
