import 'package:flutter/foundation.dart';
import '../../domain/model/transaction.dart';
import '../../domain/model/transaction_type.dart';
import '../../domain/usecase/make_transaction_usecase.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';
import '../ui/utils/money_formatter.dart';

enum ExpenseCategory {
  transport,
  gift,
  recurring,
  food,
  medicine,
  clothes,
  hygiene,
}

enum IncomeCategory { salary, gift, investment, other }

class FormUiState {
  final String date;
  final TransactionType transactionType;

  /// `.name` of an [ExpenseCategory] or an [IncomeCategory] value, or the
  /// slug of a category the user created. `null` means nothing is chosen.
  final String? categorySlug;
  final String quantity;
  final String notes;
  final bool isRecurring;
  final bool isQuantityError;

  const FormUiState({
    this.date = '',
    this.transactionType = TransactionType.expense,
    this.categorySlug,
    this.quantity = '',
    this.notes = '',
    this.isRecurring = false,
    this.isQuantityError = false,
  });

  FormUiState copyWith({
    String? date,
    TransactionType? transactionType,
    String? Function()? categorySlug,
    String? quantity,
    String? notes,
    bool? isRecurring,
    bool? isQuantityError,
  }) {
    return FormUiState(
      date: date ?? this.date,
      transactionType: transactionType ?? this.transactionType,
      categorySlug: categorySlug != null ? categorySlug() : this.categorySlug,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      isQuantityError: isQuantityError ?? this.isQuantityError,
    );
  }
}

class TransactionFormViewModel extends ChangeNotifier {
  final MakeTransactionUseCase _makeTransactionUseCase;

  FormUiState _uiState = const FormUiState();

  Transaction? _editingTransaction;

  late final Command2<int, int, int> submitCommand;

  TransactionFormViewModel({
    required MakeTransactionUseCase makeTransactionUseCase,
  }) : _makeTransactionUseCase = makeTransactionUseCase {
    submitCommand = Command2<int, int, int>(_submitTransaction);
  }

  FormUiState get uiState => _uiState;

  /// The stored transaction the form is editing, or null while the form
  /// creates a new one.
  Transaction? get editingTransaction => _editingTransaction;

  bool get isEditing => _editingTransaction != null;

  /// Fills the form from [transaction] so the dialog opens on its stored
  /// values, and puts the form in edit mode.
  void startEditing(Transaction transaction) {
    _editingTransaction = transaction;
    _uiState = FormUiState(
      date: transaction.humanDate,
      transactionType: transaction.type,
      categorySlug: transaction.category,
      quantity: formatMoney(transaction.amountCents),
      notes: transaction.description ?? '',
      isRecurring: transaction.isRecurring,
    );
    notifyListeners();
  }

  /// The edited transaction, or null while the form is not editing. It keeps
  /// the stored row's `id`, `createdAt`, `humanDate`, `targetMonth`,
  /// `targetYear`, `endMonth` and `endYear`; the use cases decide what a scope
  /// does to the last four.
  Transaction? buildEditedTransaction() {
    final original = _editingTransaction;
    if (original == null) return null;

    return original.copyWith(
      amountCents: _amountCents,
      type: _uiState.transactionType,
      category: _uiState.categorySlug,
      description: _uiState.notes,
      isRecurring: _uiState.isRecurring,
    );
  }

  int get _amountCents {
    final normalizedQuantity = _uiState.quantity.replaceAll(',', '.');
    final amountDouble = double.tryParse(normalizedQuantity) ?? 0.0;
    return (amountDouble * 100).round();
  }

  bool get isSubmitEnabled {
    final hasValidQuantity =
        _uiState.quantity.isNotEmpty && !_uiState.isQuantityError;
    return hasValidQuantity && _uiState.categorySlug != null;
  }

  /// Switching the type clears the chosen category: the two types never offer
  /// the same options, so keeping the old slug would submit a category the
  /// user cannot see in the dropdown.
  void onTransactionTypeChange(TransactionType newType) {
    _uiState = _uiState.copyWith(
      transactionType: newType,
      categorySlug: () => null,
    );
    notifyListeners();
  }

  void onCategoryChange(String newCategorySlug) {
    _uiState = _uiState.copyWith(categorySlug: () => newCategorySlug);
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
      return Result.error(Exception('Invalid form'));
    }

    final amountCents = _amountCents;

    final dateText = _uiState.date.isNotEmpty
        ? _uiState.date
        : _currentDateString();

    final monthStart = DateTime(year, month, 1).millisecondsSinceEpoch;

    final category = _uiState.categorySlug;

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
        debugPrint('Error inserting transaction: ${result.error}');
    }

    return result;
  }

  Future<void> submit(int month, int year) async {
    await submitCommand.execute(month, year);
  }

  void resetForm() {
    _editingTransaction = null;
    _uiState = const FormUiState();
    notifyListeners();
  }

  String _currentDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
