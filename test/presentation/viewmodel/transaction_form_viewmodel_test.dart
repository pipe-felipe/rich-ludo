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
    group('Estado inicial', () {
      test('deve começar com estado padrão', () {
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

      test('isSubmitEnabled deve ser false inicialmente', () {
        expect(viewModel.isSubmitEnabled, isFalse);
      });
    });

    group('onTransactionTypeChange', () {
      test('deve alterar tipo de transação para income', () {
        viewModel.onTransactionTypeChange(TransactionType.income);

        expect(
          viewModel.uiState.transactionType,
          equals(TransactionType.income),
        );
      });

      test('deve alterar tipo de transação para expense', () {
        viewModel.onTransactionTypeChange(TransactionType.income);
        viewModel.onTransactionTypeChange(TransactionType.expense);

        expect(
          viewModel.uiState.transactionType,
          equals(TransactionType.expense),
        );
      });
    });

    group('onExpenseCategoryChange', () {
      test('deve alterar categoria de despesa', () {
        viewModel.onExpenseCategoryChange(ExpenseCategory.food);

        expect(viewModel.uiState.expenseCategory, equals(ExpenseCategory.food));
      });
    });

    group('onIncomeCategoryChange', () {
      test('deve alterar categoria de receita', () {
        viewModel.onIncomeCategoryChange(IncomeCategory.salary);

        expect(viewModel.uiState.incomeCategory, equals(IncomeCategory.salary));
      });
    });

    group('onQuantityChange', () {
      test('deve aceitar valor numérico válido', () {
        viewModel.onQuantityChange('100.50');

        expect(viewModel.uiState.quantity, equals('100.50'));
        expect(viewModel.uiState.isQuantityError, isFalse);
      });

      test('deve aceitar valor com vírgula como separador decimal', () {
        viewModel.onQuantityChange('100,50');

        expect(viewModel.uiState.quantity, equals('100,50'));
        expect(viewModel.uiState.isQuantityError, isFalse);
      });

      test('deve marcar erro para valor inválido', () {
        viewModel.onQuantityChange('abc');

        expect(viewModel.uiState.quantity, equals('abc'));
        expect(viewModel.uiState.isQuantityError, isTrue);
      });

      test('não deve marcar erro para string vazia', () {
        viewModel.onQuantityChange('');

        expect(viewModel.uiState.quantity, equals(''));
        expect(viewModel.uiState.isQuantityError, isFalse);
      });
    });

    group('onNotesChange', () {
      test('deve alterar notas', () {
        viewModel.onNotesChange('Almoço de negócios');

        expect(viewModel.uiState.notes, equals('Almoço de negócios'));
      });
    });

    group('onRecurringChange', () {
      test('deve alterar estado de recorrente', () {
        viewModel.onRecurringChange(true);

        expect(viewModel.uiState.isRecurring, isTrue);
      });

      test('deve desativar estado de recorrente', () {
        viewModel.onRecurringChange(true);
        viewModel.onRecurringChange(false);

        expect(viewModel.uiState.isRecurring, isFalse);
      });
    });

    group('onDateChange', () {
      test('deve alterar data', () {
        viewModel.onDateChange('2026-02-03');

        expect(viewModel.uiState.date, equals('2026-02-03'));
      });
    });

    group('isSubmitEnabled', () {
      test('deve ser true com categoria de despesa e quantidade válida', () {
        viewModel.onExpenseCategoryChange(ExpenseCategory.food);
        viewModel.onQuantityChange('50.00');

        expect(viewModel.isSubmitEnabled, isTrue);
      });

      test('deve ser true com categoria de receita e quantidade válida', () {
        viewModel.onTransactionTypeChange(TransactionType.income);
        viewModel.onIncomeCategoryChange(IncomeCategory.salary);
        viewModel.onQuantityChange('1000');

        expect(viewModel.isSubmitEnabled, isTrue);
      });

      test('deve ser false sem categoria', () {
        viewModel.onQuantityChange('50.00');

        expect(viewModel.isSubmitEnabled, isFalse);
      });

      test('deve ser false sem quantidade', () {
        viewModel.onExpenseCategoryChange(ExpenseCategory.food);

        expect(viewModel.isSubmitEnabled, isFalse);
      });

      test('deve ser false com quantidade inválida', () {
        viewModel.onExpenseCategoryChange(ExpenseCategory.food);
        viewModel.onQuantityChange('abc');

        expect(viewModel.isSubmitEnabled, isFalse);
      });
    });

    group('submitCommand', () {
      test('deve criar transação com dados corretos via Command', () async {
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

      test('deve ter estado running durante execução', () async {
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

      test('deve resetar formulário após submit bem-sucedido', () async {
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

      test('deve ter estado error quando falha', () async {
        when(
          () => mockMakeTransactionUseCase(any()),
        ).thenAnswer((_) async => Result.error(Exception('Database error')));

        viewModel.onExpenseCategoryChange(ExpenseCategory.food);
        viewModel.onQuantityChange('50.50');

        await viewModel.submitCommand.execute(2, 2026);

        expect(viewModel.submitCommand.error, isTrue);
      });

      test('não deve submeter quando isSubmitEnabled é false', () async {
        await viewModel.submitCommand.execute(2, 2026);

        verifyNever(() => mockMakeTransactionUseCase(any()));
      });
    });

    group('resetForm', () {
      test('deve resetar todos os campos', () {
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
