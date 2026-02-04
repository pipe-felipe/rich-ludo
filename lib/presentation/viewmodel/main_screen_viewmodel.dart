import 'package:flutter/foundation.dart';
import '../../domain/model/transaction.dart';
import '../../domain/model/transaction_type.dart';
import '../../domain/usecase/delete_transaction_usecase.dart';
import '../../domain/usecase/get_transactions_usecase.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// ViewModel da tela principal
/// Seguindo: https://docs.flutter.dev/app-architecture/case-study/ui-layer#define-a-view-model
class MainScreenViewModel extends ChangeNotifier {
  final GetTransactionsUseCase _getTransactionsUseCase;
  final DeleteTransactionUseCase _deleteTransactionUseCase;

  List<Transaction> _allItems = [];
  List<Transaction> _items = [];
  String _totalIncomeText = 'R\$ 0.00';
  String _totalExpenseText = 'R\$ 0.00';
  String _totalSavingText = 'R\$ 0.00';
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;
  String _currentMonthYearText = '';

  /// Command para carregar transações
  late final Command0<List<Transaction>> load;
  
  /// Command para deletar uma transação
  late final Command1<int, int> deleteTransaction;

  MainScreenViewModel({
    required GetTransactionsUseCase getTransactionsUseCase,
    required DeleteTransactionUseCase deleteTransactionUseCase,
  })  : _getTransactionsUseCase = getTransactionsUseCase,
        _deleteTransactionUseCase = deleteTransactionUseCase {
    _currentMonthYearText = _formatMonthYear(_currentMonth, _currentYear);
    
    // Inicializa Commands
    load = Command0<List<Transaction>>(_loadTransactions);
    deleteTransaction = Command1<int, int>(_deleteItem);
    
    // Carrega dados iniciais
    load.execute();
  }

  List<Transaction> get items => _items;
  String get totalIncomeText => _totalIncomeText;
  String get totalExpenseText => _totalExpenseText;
  String get totalSavingText => _totalSavingText;
  int get currentMonth => _currentMonth;
  int get currentYear => _currentYear;
  String get currentMonthYearText => _currentMonthYearText;

  Future<Result<List<Transaction>>> _loadTransactions() async {
    final result = await _getTransactionsUseCase();
    
    switch (result) {
      case Ok<List<Transaction>>(:final value):
        _allItems = value;
        _filterAndComputeTotals();
      case Error<List<Transaction>>():
        debugPrint('Erro ao carregar transações: ${result.error}');
    }
    
    return result;
  }

  Future<Result<int>> _deleteItem(int id) async {
    final result = await _deleteTransactionUseCase(id);
    
    switch (result) {
      case Ok<int>():
        // Recarrega as transações após deletar
        await _loadTransactions();
      case Error<int>():
        debugPrint('Erro ao deletar item: ${result.error}');
    }
    
    return result;
  }

  void _filterAndComputeTotals() {
    // Filtrar transações para o mês atual
    _items = _allItems.where((tx) {
      if (tx.isRecurring) {
        // Transações recorrentes aparecem a partir do mês de início
        return (tx.targetYear < _currentYear) ||
            (tx.targetYear == _currentYear && tx.targetMonth <= _currentMonth);
      } else {
        // Transações não recorrentes aparecem apenas no mês alvo
        return tx.targetMonth == _currentMonth && tx.targetYear == _currentYear;
      }
    }).toList();

    // Calcular totais do mês
    final totals = _computeTotals(_items);
    _totalIncomeText = 'R\$ ${_formatTwoDecimals(totals.$1)}';
    _totalExpenseText = 'R\$ ${_formatTwoDecimals(totals.$2)}';

    // Calcular economia acumulada
    final now = DateTime.now();
    final accumulatedItems = _allItems.where((tx) {
      return (tx.targetYear < _currentYear) ||
          (tx.targetYear == _currentYear && tx.targetMonth <= _currentMonth);
    }).toList();

    final savingsTotals = _computeTotalsForSavings(
      accumulatedItems,
      now.month,
      now.year,
    );
    _totalSavingText = 'R\$ ${_formatTwoDecimals(savingsTotals.$1 - savingsTotals.$2)}';

    notifyListeners();
  }

  (double income, double expense) _computeTotals(List<Transaction> items) {
    int incomeCents = 0;
    int expenseCents = 0;

    for (final item in items) {
      if (item.type == TransactionType.income) {
        incomeCents += item.amountCents;
      } else {
        expenseCents += item.amountCents;
      }
    }

    return (incomeCents / 100.0, expenseCents / 100.0);
  }

  (double income, double expense) _computeTotalsForSavings(
    List<Transaction> items,
    int currentMonth,
    int currentYear,
  ) {
    int incomeCents = 0;
    int expenseCents = 0;

    for (final item in items) {
      if (item.type == TransactionType.income) {
        // Apenas contar renda se não for no futuro
        final isFuture = (item.targetYear > currentYear) ||
            (item.targetYear == currentYear && item.targetMonth > currentMonth);
        if (!isFuture) {
          incomeCents += item.amountCents;
        }
      } else {
        expenseCents += item.amountCents;
      }
    }

    return (incomeCents / 100.0, expenseCents / 100.0);
  }

  String _formatTwoDecimals(double value) {
    final cents = (value * 100).round();
    final negative = cents < 0;
    final absCents = cents.abs();
    final whole = absCents ~/ 100;
    final fraction = (absCents % 100).toString().padLeft(2, '0');
    final sign = negative ? '-' : '';
    return '$sign$whole.$fraction';
  }

  String _formatMonthYear(int month, int year) {
    const monthNames = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return '${monthNames[month - 1]} $year';
  }

  /// Deleta um item usando o Command
  void deleteItem(int id) {
    deleteTransaction.execute(id);
  }

  void goToPreviousMonth() {
    if (_currentMonth == 1) {
      _currentMonth = 12;
      _currentYear--;
    } else {
      _currentMonth--;
    }
    _currentMonthYearText = _formatMonthYear(_currentMonth, _currentYear);
    _filterAndComputeTotals();
  }

  void goToNextMonth() {
    if (_currentMonth == 12) {
      _currentMonth = 1;
      _currentYear++;
    } else {
      _currentMonth++;
    }
    _currentMonthYearText = _formatMonthYear(_currentMonth, _currentYear);
    _filterAndComputeTotals();
  }

  void goToCurrentMonth() {
    final now = DateTime.now();
    _currentMonth = now.month;
    _currentYear = now.year;
    _currentMonthYearText = _formatMonthYear(_currentMonth, _currentYear);
    _filterAndComputeTotals();
  }
}
