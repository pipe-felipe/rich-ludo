import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rich_ludo/domain/model/recurring_exclusion.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/domain/usecase/delete_recurring_transaction_usecase.dart';
import 'package:rich_ludo/domain/usecase/delete_transaction_usecase.dart';
import 'package:rich_ludo/domain/usecase/export_database_usecase.dart';
import 'package:rich_ludo/domain/usecase/get_exclusions_usecase.dart';
import 'package:rich_ludo/domain/usecase/get_transactions_usecase.dart';
import 'package:rich_ludo/domain/usecase/import_database_usecase.dart';
import 'package:rich_ludo/presentation/viewmodel/main_screen_viewmodel.dart';
import 'package:rich_ludo/utils/result.dart';

class MockGetTransactionsUseCase extends Mock
    implements GetTransactionsUseCase {}

class MockDeleteTransactionUseCase extends Mock
    implements DeleteTransactionUseCase {}

class MockDeleteRecurringTransactionUseCase extends Mock
    implements DeleteRecurringTransactionUseCase {}

class MockGetExclusionsUseCase extends Mock implements GetExclusionsUseCase {}

class MockExportDatabaseUseCase extends Mock implements ExportDatabaseUseCase {}

class MockImportDatabaseUseCase extends Mock implements ImportDatabaseUseCase {}

void main() {
  late MockGetTransactionsUseCase mockGetTransactionsUseCase;
  late MockDeleteTransactionUseCase mockDeleteTransactionUseCase;
  late MockDeleteRecurringTransactionUseCase
  mockDeleteRecurringTransactionUseCase;
  late MockGetExclusionsUseCase mockGetExclusionsUseCase;
  late MockExportDatabaseUseCase mockExportDatabaseUseCase;
  late MockImportDatabaseUseCase mockImportDatabaseUseCase;

  setUp(() {
    mockGetTransactionsUseCase = MockGetTransactionsUseCase();
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
  }) {
    when(
      () => mockGetTransactionsUseCase(),
    ).thenAnswer((_) async => Result.ok(initialTransactions));
    when(
      () => mockGetExclusionsUseCase(),
    ).thenAnswer((_) async => Result.ok(initialExclusions));

    return MainScreenViewModel(
      getTransactionsUseCase: mockGetTransactionsUseCase,
      deleteTransactionUseCase: mockDeleteTransactionUseCase,
      deleteRecurringTransactionUseCase: mockDeleteRecurringTransactionUseCase,
      getExclusionsUseCase: mockGetExclusionsUseCase,
      exportDatabaseUseCase: mockExportDatabaseUseCase,
      importDatabaseUseCase: mockImportDatabaseUseCase,
    );
  }

  group('MainScreenViewModel', () {
    group('Initial State', () {
      test('should start with an empty list of items', () async {
        final viewModel = createViewModel();

        // Aguardar o Command completar
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
          () => mockGetTransactionsUseCase(),
        ).thenAnswer((_) async => Result.error(Exception('Database error')));
        when(
          () => mockGetExclusionsUseCase(),
        ).thenAnswer((_) async => const Result.ok(<RecurringExclusion>[]));

        final viewModel = MainScreenViewModel(
          getTransactionsUseCase: mockGetTransactionsUseCase,
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

        // Navegar até dezembro
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

          // Navegar até janeiro
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

        // Navegar para longe
        viewModel.goToNextMonth();
        viewModel.goToNextMonth();
        viewModel.goToNextMonth();

        viewModel.goToCurrentMonth();

        expect(viewModel.currentMonth, equals(now.month));
        expect(viewModel.currentYear, equals(now.year));

        viewModel.dispose();
      });
    });

    group('Transactions Update', () {
      test('should update items when load executes successfully', () async {
        final now = DateTime.now();

        final transactions = [
          Transaction(
            id: 1,
            amountCents: 1000,
            type: TransactionType.income,
            description: 'Salário',
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
            description: 'Salário',
            targetMonth: now.month,
            targetYear: now.year,
          ),
          Transaction(
            id: 2,
            amountCents: 5000, // R$ 50.00
            type: TransactionType.income,
            description: 'Bônus',
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
            description: 'Almoço',
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
            description: 'Transação do mês atual',
            isRecurring: false,
            targetMonth: now.month,
            targetYear: now.year,
          ),
          Transaction(
            id: 2,
            amountCents: 3000,
            type: TransactionType.expense,
            description: 'Transação do próximo mês',
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
          equals('Transação do mês atual'),
        );

        viewModel.dispose();
      });
    });
  });
}
