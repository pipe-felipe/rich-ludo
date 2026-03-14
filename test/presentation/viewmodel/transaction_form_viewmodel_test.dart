import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/domain/usecase/make_transaction_usecase.dart';
import 'package:rich_ludo/presentation/viewmodel/transaction_form_viewmodel.dart';
import 'package:rich_ludo/utils/result.dart';

class MockMakeTransactionUseCase extends Mock
    implements MakeTransactionUseCase {}

class FakeTransaction extends Fake implements Transaction {}

void main() {
  late MockMakeTransactionUseCase mockMakeTransactionUseCase;
  late TransactionFormViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(FakeTransaction());
  });

  setUp(() {
    mockMakeTransactionUseCase = MockMakeTransactionUseCase();
    viewModel = TransactionFormViewModel(
      makeTransactionUseCase: mockMakeTransactionUseCase,
    );
  });

  group('TransactionFormViewModel', () {
    group('Initial State', () {
      test('should start with an empty list of items', () async {
        final state = viewModel.uiState;

        expect(state.date, equals(''));
        expect(state.transactionType, equals(TransactionType.expense));
        expect(state.expenseCategory, isNull);
        expect(state.incomeCategory, isNull);
        expect(state.quantity, equals(''));
        expect(state.notes, equals(''));
        expect(state.isRecurring, isFalse);
        expect(state.isQuantityError, isFalse);
      });

      test('isSubmitEnabled should be false initially', () {
        expect(viewModel.isSubmitEnabled, isFalse);
      });
    });

    group('onTransactionTypeChange', () {
      test('should change transaction type to income', () {
        viewModel.onTransactionTypeChange(TransactionType.income);

        expect(
          viewModel.uiState.transactionType,
          equals(TransactionType.income),
        );
      });

      test('should change transaction type to expense', () {
        viewModel.onTransactionTypeChange(TransactionType.income);
        viewModel.onTransactionTypeChange(TransactionType.expense);

        expect(
          viewModel.uiState.transactionType,
          equals(TransactionType.expense),
        );
      });
    });

    group('onExpenseCategoryChange', () {
      test('should change expense category', () {
        viewModel.onExpenseCategoryChange(ExpenseCategory.food);

        expect(viewModel.uiState.expenseCategory, equals(ExpenseCategory.food));
      });
    });

    group('onIncomeCategoryChange', () {
      test('should change income category', () {
        viewModel.onIncomeCategoryChange(IncomeCategory.salary);

        expect(viewModel.uiState.incomeCategory, equals(IncomeCategory.salary));
      });
    });

    group('onQuantityChange', () {
      test('should accept valid numeric value', () {
        viewModel.onQuantityChange('100.50');

        expect(viewModel.uiState.quantity, equals('100.50'));
        expect(viewModel.uiState.isQuantityError, isFalse);
      });

      test('should accept comma as decimal separator', () {
        viewModel.onQuantityChange('100,50');

        expect(viewModel.uiState.quantity, equals('100,50'));
        expect(viewModel.uiState.isQuantityError, isFalse);
      });

      test('should flag error for invalid value', () {
        viewModel.onQuantityChange('abc');

        expect(viewModel.uiState.quantity, equals('abc'));
        expect(viewModel.uiState.isQuantityError, isTrue);
      });

      test('should not flag error for empty string', () {
        viewModel.onQuantityChange('');

        expect(viewModel.uiState.quantity, equals(''));
        expect(viewModel.uiState.isQuantityError, isFalse);
      });
    });

    group('onNotesChange', () {
      test('should change notes', () {
        viewModel.onNotesChange('Almoço de negócios');

        expect(viewModel.uiState.notes, equals('Almoço de negócios'));
      });
    });

    group('onRecurringChange', () {
      test('should change recurring state', () {
        viewModel.onRecurringChange(true);

        expect(viewModel.uiState.isRecurring, isTrue);
      });

      test('should disable recurring state', () {
        viewModel.onRecurringChange(true);
        viewModel.onRecurringChange(false);

        expect(viewModel.uiState.isRecurring, isFalse);
      });
    });

    group('onDateChange', () {
      test('should change date', () {
        viewModel.onDateChange('2026-02-03');

        expect(viewModel.uiState.date, equals('2026-02-03'));
      });
    });

    group('isSubmitEnabled', () {
      test('should be true with valid expense category and quantity', () {
        viewModel.onExpenseCategoryChange(ExpenseCategory.food);
        viewModel.onQuantityChange('50.00');

        expect(viewModel.isSubmitEnabled, isTrue);
      });

      test('should be true with valid income category and quantity', () {
        viewModel.onTransactionTypeChange(TransactionType.income);
        viewModel.onIncomeCategoryChange(IncomeCategory.salary);
        viewModel.onQuantityChange('1000');

        expect(viewModel.isSubmitEnabled, isTrue);
      });

      test('should be false without category', () {
        viewModel.onQuantityChange('50.00');

        expect(viewModel.isSubmitEnabled, isFalse);
      });

      test('should be false without quantity', () {
        viewModel.onExpenseCategoryChange(ExpenseCategory.food);

        expect(viewModel.isSubmitEnabled, isFalse);
      });

      test('should be false with invalid quantity', () {
        viewModel.onExpenseCategoryChange(ExpenseCategory.food);
        viewModel.onQuantityChange('abc');

        expect(viewModel.isSubmitEnabled, isFalse);
      });
    });

    group('submitCommand', () {
      test('should create transaction with correct data via Command', () async {
        when(
          () => mockMakeTransactionUseCase(any()),
        ).thenAnswer((_) async => Result.ok(1));

        viewModel.onExpenseCategoryChange(ExpenseCategory.food);
        viewModel.onQuantityChange('50.50');
        viewModel.onNotesChange('Almoço');
        viewModel.onRecurringChange(false);

        await viewModel.submitCommand.execute(2, 2026);

        verify(() => mockMakeTransactionUseCase(any())).called(1);
      });

      test('should have running state during execution', () async {
        when(
          () => mockMakeTransactionUseCase(any()),
        ).thenAnswer((_) async => Result.ok(1));

        viewModel.onExpenseCategoryChange(ExpenseCategory.food);
        viewModel.onQuantityChange('50.50');

        final future = viewModel.submitCommand.execute(2, 2026);

        expect(viewModel.submitCommand.running, isTrue);

        await future;

        expect(viewModel.submitCommand.running, isFalse);
        expect(viewModel.submitCommand.completed, isTrue);
      });

      test('should reset form after successful submit', () async {
        when(
          () => mockMakeTransactionUseCase(any()),
        ).thenAnswer((_) async => Result.ok(1));

        viewModel.onExpenseCategoryChange(ExpenseCategory.food);
        viewModel.onQuantityChange('50.50');
        viewModel.onNotesChange('Almoço');

        await viewModel.submitCommand.execute(2, 2026);

        expect(viewModel.uiState.quantity, equals(''));
        expect(viewModel.uiState.notes, equals(''));
        expect(viewModel.uiState.expenseCategory, isNull);
      });

      test('should have error state when failed', () async {
        when(
          () => mockMakeTransactionUseCase(any()),
        ).thenAnswer((_) async => Result.error(Exception('Database error')));

        viewModel.onExpenseCategoryChange(ExpenseCategory.food);
        viewModel.onQuantityChange('50.50');

        await viewModel.submitCommand.execute(2, 2026);

        expect(viewModel.submitCommand.error, isTrue);
      });

      test('should not submit when isSubmitEnabled is false', () async {
        await viewModel.submitCommand.execute(2, 2026);

        verifyNever(() => mockMakeTransactionUseCase(any()));
      });
    });

    group('resetForm', () {
      test('should reset all fields', () {
        viewModel.onTransactionTypeChange(TransactionType.income);
        viewModel.onIncomeCategoryChange(IncomeCategory.salary);
        viewModel.onQuantityChange('1000');
        viewModel.onNotesChange('Salário');
        viewModel.onRecurringChange(true);
        viewModel.onDateChange('2026-02-01');

        viewModel.resetForm();

        final state = viewModel.uiState;
        expect(state.date, equals(''));
        expect(state.transactionType, equals(TransactionType.expense));
        expect(state.expenseCategory, isNull);
        expect(state.incomeCategory, isNull);
        expect(state.quantity, equals(''));
        expect(state.notes, equals(''));
        expect(state.isRecurring, isFalse);
      });
    });
  });
}
