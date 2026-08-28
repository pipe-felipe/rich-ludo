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

  Transaction storedTransaction({
    int amountCents = 5000,
    bool isRecurring = false,
  }) {
    return Transaction(
      id: 42,
      amountCents: amountCents,
      type: TransactionType.expense,
      category: 'food',
      description: 'Lunch',
      humanDate: '2026-08-04',
      isRecurring: isRecurring,
      createdAt: 1754006400000,
      targetMonth: 8,
      targetYear: 2026,
    );
  }

  group('TransactionFormViewModel', () {
    group('Initial State', () {
      test('should start with an empty list of items', () async {
        final state = viewModel.uiState;

        expect(state.date, equals(''));
        expect(state.transactionType, equals(TransactionType.expense));
        expect(state.categorySlug, isNull);
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

    group('onCategoryChange', () {
      test('should change the category slug', () {
        viewModel.onCategoryChange('food');

        expect(viewModel.uiState.categorySlug, equals('food'));
      });

      test('should accept a user-created slug', () {
        viewModel.onCategoryChange('custom_mercado');

        expect(viewModel.uiState.categorySlug, equals('custom_mercado'));
      });
    });

    group('onTransactionTypeChange clearing', () {
      test('should clear the category slug when the type changes', () {
        viewModel.onCategoryChange('food');

        viewModel.onTransactionTypeChange(TransactionType.income);

        expect(viewModel.uiState.categorySlug, isNull);
        expect(viewModel.isSubmitEnabled, isFalse);
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
        viewModel.onNotesChange('Business lunch');

        expect(viewModel.uiState.notes, equals('Business lunch'));
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
        viewModel.onCategoryChange('food');
        viewModel.onQuantityChange('50.00');

        expect(viewModel.isSubmitEnabled, isTrue);
      });

      test('should be true with valid income category and quantity', () {
        viewModel.onTransactionTypeChange(TransactionType.income);
        viewModel.onCategoryChange('salary');
        viewModel.onQuantityChange('1000');

        expect(viewModel.isSubmitEnabled, isTrue);
      });

      test('should be false without category', () {
        viewModel.onQuantityChange('50.00');

        expect(viewModel.isSubmitEnabled, isFalse);
      });

      test('should be false without quantity', () {
        viewModel.onCategoryChange('food');

        expect(viewModel.isSubmitEnabled, isFalse);
      });

      test('should be false with invalid quantity', () {
        viewModel.onCategoryChange('food');
        viewModel.onQuantityChange('abc');

        expect(viewModel.isSubmitEnabled, isFalse);
      });
    });

    group('submitCommand', () {
      test('should create transaction with correct data via Command', () async {
        when(
          () => mockMakeTransactionUseCase(any()),
        ).thenAnswer((_) async => Result.ok(1));

        viewModel.onCategoryChange('food');
        viewModel.onQuantityChange('50.50');
        viewModel.onNotesChange('Lunch');
        viewModel.onRecurringChange(false);

        await viewModel.submitCommand.execute(2, 2026);

        verify(() => mockMakeTransactionUseCase(any())).called(1);
      });

      test(
        'should submit the user-created slug in the category field',
        () async {
          when(
            () => mockMakeTransactionUseCase(any()),
          ).thenAnswer((_) async => Result.ok(1));

          viewModel.onCategoryChange('custom_mercado');
          viewModel.onQuantityChange('12.00');

          await viewModel.submitCommand.execute(2, 2026);

          final captured =
              verify(
                    () => mockMakeTransactionUseCase(captureAny()),
                  ).captured.single
                  as Transaction;
          expect(captured.category, equals('custom_mercado'));
        },
      );

      test('should have running state during execution', () async {
        when(
          () => mockMakeTransactionUseCase(any()),
        ).thenAnswer((_) async => Result.ok(1));

        viewModel.onCategoryChange('food');
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

        viewModel.onCategoryChange('food');
        viewModel.onQuantityChange('50.50');
        viewModel.onNotesChange('Lunch');

        await viewModel.submitCommand.execute(2, 2026);

        expect(viewModel.uiState.quantity, equals(''));
        expect(viewModel.uiState.notes, equals(''));
        expect(viewModel.uiState.categorySlug, isNull);
      });

      test('should have error state when failed', () async {
        when(
          () => mockMakeTransactionUseCase(any()),
        ).thenAnswer((_) async => Result.error(Exception('Database error')));

        viewModel.onCategoryChange('food');
        viewModel.onQuantityChange('50.50');

        await viewModel.submitCommand.execute(2, 2026);

        expect(viewModel.submitCommand.error, isTrue);
      });

      test('should not submit when isSubmitEnabled is false', () async {
        await viewModel.submitCommand.execute(2, 2026);

        verifyNever(() => mockMakeTransactionUseCase(any()));
      });
    });

    group('startEditing', () {
      test('should fill the form from the stored transaction', () {
        viewModel.startEditing(storedTransaction());

        final state = viewModel.uiState;
        expect(state.transactionType, equals(TransactionType.expense));
        expect(state.categorySlug, equals('food'));
        expect(state.quantity, equals('50.00'));
        expect(state.notes, equals('Lunch'));
        expect(state.date, equals('2026-08-04'));
        expect(state.isRecurring, isFalse);
      });

      test('should report isEditing and expose the stored transaction', () {
        viewModel.startEditing(storedTransaction());

        expect(viewModel.isEditing, isTrue);
        expect(viewModel.editingTransaction!.id, equals(42));
      });

      test('should enable submit right away', () {
        viewModel.startEditing(storedTransaction());

        expect(viewModel.isSubmitEnabled, isTrue);
      });
    });

    group('buildEditedTransaction', () {
      test('should return null when the form is not editing', () {
        expect(viewModel.buildEditedTransaction(), isNull);
      });

      test(
        'should keep the id, createdAt, humanDate, month and year of the stored row',
        () {
          viewModel.startEditing(storedTransaction());
          viewModel.onQuantityChange('99');

          final edited = viewModel.buildEditedTransaction()!;

          expect(edited.id, equals(42));
          expect(edited.createdAt, equals(1754006400000));
          expect(edited.humanDate, equals('2026-08-04'));
          expect(edited.targetMonth, equals(8));
          expect(edited.targetYear, equals(2026));
        },
      );

      test(
        'should carry the edited amount, type, category, notes and recurring flag',
        () {
          viewModel.startEditing(storedTransaction());
          viewModel.onQuantityChange('12,50');
          viewModel.onNotesChange('Dinner');
          viewModel.onRecurringChange(true);

          final edited = viewModel.buildEditedTransaction()!;

          expect(edited.amountCents, equals(1250));
          expect(edited.category, equals('food'));
          expect(edited.description, equals('Dinner'));
          expect(edited.isRecurring, isTrue);
        },
      );

      test('should carry the category chosen after a type change', () {
        viewModel.startEditing(storedTransaction());
        viewModel.onTransactionTypeChange(TransactionType.income);
        viewModel.onCategoryChange('salary');

        final edited = viewModel.buildEditedTransaction()!;

        expect(edited.type, equals(TransactionType.income));
        expect(edited.category, equals('salary'));
      });
    });

    group('resetForm', () {
      test('should reset all fields', () {
        viewModel.onTransactionTypeChange(TransactionType.income);
        viewModel.onCategoryChange('salary');
        viewModel.onQuantityChange('1000');
        viewModel.onNotesChange('Salary');
        viewModel.onRecurringChange(true);
        viewModel.onDateChange('2026-02-01');

        viewModel.resetForm();

        final state = viewModel.uiState;
        expect(state.date, equals(''));
        expect(state.transactionType, equals(TransactionType.expense));
        expect(state.categorySlug, isNull);
        expect(state.quantity, equals(''));
        expect(state.notes, equals(''));
        expect(state.isRecurring, isFalse);
      });

      test('should leave edit mode', () {
        viewModel.startEditing(storedTransaction());

        viewModel.resetForm();

        expect(viewModel.isEditing, isFalse);
        expect(viewModel.buildEditedTransaction(), isNull);
      });
    });
  });
}
