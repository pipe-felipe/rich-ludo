import 'package:flutter/foundation.dart';
import '../../domain/model/transaction.dart';
import '../../domain/model/transaction_type.dart';
import '../../domain/usecase/make_transaction_usecase.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

enum ExpenseCategory {
  transport,
  gift,
  recurring,
  food,
  stuff,
  medicine,
  clothes,
}

enum IncomeCategory {
  salary,
  gift,
  investment,
  other,
}

class FormUiState {
  final String date;
  final TransactionType transactionType;
  final ExpenseCategory? expenseCategory;
  final IncomeCategory? incomeCategory;
  final String quantity;
  final String notes;
  final bool isRecurring;
  final bool isQuantityError;

  const FormUiState({
    this.date = '',
    this.transactionType = TransactionType.expense,
    this.expenseCategory,
    this.incomeCategory,
    this.quantity = '',
    this.notes = '',
    this.isRecurring = false,
    this.isQuantityError = false,
  });

  FormUiState copyWith({
    String? date,
    TransactionType? transactionType,
    ExpenseCategory? expenseCategory,
    IncomeCategory? incomeCategory,
    String? quantity,
    String? notes,
    bool? isRecurring,
    bool? isQuantityError,
  }) {
    return FormUiState(
      date: date ?? this.date,
      transactionType: transactionType ?? this.transactionType,
      expenseCategory: expenseCategory ?? this.expenseCategory,
      incomeCategory: incomeCategory ?? this.incomeCategory,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      isQuantityError: isQuantityError ?? this.isQuantityError,
    );
  }
}

/// ViewModel para o formulário de transação
/// Seguindo: https://docs.flutter.dev/app-architecture/case-study/ui-layer#define-a-view-model
class TransactionFormViewModel extends ChangeNotifier {
  final MakeTransactionUseCase _makeTransactionUseCase;

  FormUiState _uiState = const FormUiState();

  /// Command para submeter o formulário
  late final Command2<int, int, int> submitCommand;

  TransactionFormViewModel({
    required MakeTransactionUseCase makeTransactionUseCase,
  }) : _makeTransactionUseCase = makeTransactionUseCase {
    submitCommand = Command2<int, int, int>(_submitTransaction);
  }

  FormUiState get uiState => _uiState;

  bool get isSubmitEnabled {
    final hasValidQuantity = _uiState.quantity.isNotEmpty && !_uiState.isQuantityError;
    final hasCategory = _uiState.transactionType == TransactionType.expense
        ? _uiState.expenseCategory != null
        : _uiState.incomeCategory != null;
    return hasValidQuantity && hasCategory;
  }

  void onTransactionTypeChange(TransactionType newType) {
    _uiState = _uiState.copyWith(transactionType: newType);
    notifyListeners();
  }

  void onExpenseCategoryChange(ExpenseCategory newCategory) {
    _uiState = _uiState.copyWith(expenseCategory: newCategory);
    notifyListeners();
  }

  void onIncomeCategoryChange(IncomeCategory newCategory) {
    _uiState = _uiState.copyWith(incomeCategory: newCategory);
    notifyListeners();
  }

  void onQuantityChange(String input) {
    final normalizedInput = input.replaceAll(',', '.');
    final isValid = double.tryParse(normalizedInput) != null;

    _uiState = _uiState.copyWith(
      quantity: input,
      isQuantityError: input.isNotEmpty && !isValid,
    );
    notifyListeners();
  }

  void onNotesChange(String newText) {
    _uiState = _uiState.copyWith(notes: newText);
    notifyListeners();
  }

  void onRecurringChange(bool isChecked) {
    _uiState = _uiState.copyWith(isRecurring: isChecked);
    notifyListeners();
  }

  void onDateChange(String newDate) {
    _uiState = _uiState.copyWith(date: newDate);
    notifyListeners();
  }

  Future<Result<int>> _submitTransaction(int month, int year) async {
    if (!isSubmitEnabled) {
      return Result.error(Exception('Formulário inválido'));
    }

    final normalizedQuantity = _uiState.quantity.replaceAll(',', '.');
    final amountDouble = double.tryParse(normalizedQuantity) ?? 0.0;
    final amountCents = (amountDouble * 100).round();

    // Usar data atual se não fornecida
    final dateText = _uiState.date.isNotEmpty
        ? _uiState.date
        : _currentDateString();

    // Calcular createdAt como início do mês selecionado
    final monthStart = DateTime(year, month, 1).millisecondsSinceEpoch;

    final category = _uiState.transactionType == TransactionType.expense
        ? _uiState.expenseCategory?.name
        : _uiState.incomeCategory?.name;

    final transaction = Transaction(
      amountCents: amountCents,
      type: _uiState.transactionType,
      category: category,
      description: _uiState.notes,
      humanDate: dateText,
      isRecurring: _uiState.isRecurring,
      createdAt: monthStart,
      targetMonth: month,
      targetYear: year,
    );

    final result = await _makeTransactionUseCase(transaction);
    
    switch (result) {
      case Ok<int>():
        resetForm();
      case Error<int>():
        debugPrint('Erro ao inserir transação: ${result.error}');
    }
    
    return result;
  }

  Future<void> submit(int month, int year) async {
    await submitCommand.execute(month, year);
  }

  void resetForm() {
    _uiState = const FormUiState();
    notifyListeners();
  }

  String _currentDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
