import 'package:flutter/foundation.dart';
import '../../domain/model/recurring_exclusion.dart';
import '../../domain/model/transaction.dart';
import '../../domain/model/transaction_type.dart';
import '../../domain/usecase/delete_recurring_transaction_usecase.dart';
import '../../domain/usecase/delete_transaction_usecase.dart';
import '../../domain/usecase/export_database_usecase.dart';
import '../../domain/usecase/get_exclusions_usecase.dart';
import '../../domain/usecase/get_transactions_usecase.dart';
import '../../domain/usecase/import_database_usecase.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';
import '../ui/utils/money_formatter.dart';

class MainScreenViewModel extends ChangeNotifier {
  final GetTransactionsUseCase _getTransactionsUseCase;
  final DeleteTransactionUseCase _deleteTransactionUseCase;
  final DeleteRecurringTransactionUseCase _deleteRecurringTransactionUseCase;
  final GetExclusionsUseCase _getExclusionsUseCase;
  final ExportDatabaseUseCase _exportDatabaseUseCase;
  final ImportDatabaseUseCase _importDatabaseUseCase;

  List<Transaction> _allItems = [];
  List<RecurringExclusion> _exclusions = [];
  List<Transaction> _items = [];
  String _totalIncomeText = 'R\$ 0.00';
  String _totalExpenseText = 'R\$ 0.00';
  String _totalSavingText = 'R\$ 0.00';
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;
  String _currentMonthYearText = '';

  late final Command0<List<Transaction>> load;
  
  late final Command1<int, int> deleteTransaction;

  late final Command0<String> exportDatabase;

  late final Command0<void> importDatabase;

  MainScreenViewModel({
    required GetTransactionsUseCase getTransactionsUseCase,
    required DeleteTransactionUseCase deleteTransactionUseCase,
    required DeleteRecurringTransactionUseCase deleteRecurringTransactionUseCase,
    required GetExclusionsUseCase getExclusionsUseCase,
    required ExportDatabaseUseCase exportDatabaseUseCase,
    required ImportDatabaseUseCase importDatabaseUseCase,
  })  : _getTransactionsUseCase = getTransactionsUseCase,
        _deleteTransactionUseCase = deleteTransactionUseCase,
        _deleteRecurringTransactionUseCase = deleteRecurringTransactionUseCase,
        _getExclusionsUseCase = getExclusionsUseCase,
        _exportDatabaseUseCase = exportDatabaseUseCase,
        _importDatabaseUseCase = importDatabaseUseCase {
    _currentMonthYearText = _formatMonthYear(_currentMonth, _currentYear);

    load = Command0<List<Transaction>>(_loadTransactions);
    deleteTransaction = Command1<int, int>(_deleteItem);
    exportDatabase = Command0<String>(_exportDatabaseUseCase.call);
    importDatabase = Command0<void>(_importDatabaseUseCase.call);

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
    final results = await Future.wait([
      _getTransactionsUseCase(),
      _getExclusionsUseCase(),
    ]);

    final result = results[0] as Result<List<Transaction>>;
    final exclusionsResult = results[1] as Result<List<RecurringExclusion>>;
    
    switch (result) {
      case Ok<List<Transaction>>(:final value):
        _allItems = value;
      case Error<List<Transaction>>():
        debugPrint('Erro ao carregar transações: ${result.error}');
    }

    switch (exclusionsResult) {
      case Ok<List<RecurringExclusion>>(:final value):
        _exclusions = value;
      case Error<List<RecurringExclusion>>():
        debugPrint('Erro ao carregar exclusões: ${exclusionsResult.error}');
    }

    _filterAndComputeTotals();
    return result;
  }

  Future<Result<int>> _deleteItem(int id) async {
    final result = await _deleteTransactionUseCase(id);
    
    switch (result) {
      case Ok<int>():
        await _loadTransactions();
      case Error<int>():
        debugPrint('Erro ao deletar item: ${result.error}');
    }
    
    return result;
  }

  void _filterAndComputeTotals() {
    _items = _visibleItemsForMonth(_currentMonth, _currentYear);
    _totalIncomeText = _formatCurrency(_sumByType(_items, TransactionType.income));
    _totalExpenseText = _formatCurrency(_sumByType(_items, TransactionType.expense));
    _totalSavingText = _formatCurrency(_computeSavingsCents());
    notifyListeners();
  }

  List<Transaction> _visibleItemsForMonth(int month, int year) {
    return _allItems.where((tx) {
      if (tx.isRecurring) {
        return _isRecurringActiveInMonth(tx, month, year) &&
            !_isExcludedInMonth(tx.id, month, year);
      }
      return tx.targetMonth == month && tx.targetYear == year;
    }).toList();
  }

  bool _isRecurringActiveInMonth(Transaction tx, int month, int year) {
    final afterStart =
        tx.targetYear < year || (tx.targetYear == year && tx.targetMonth <= month);
    final beforeEnd = tx.endMonth == null ||
        tx.endYear == null ||
        year < tx.endYear! ||
        (year == tx.endYear! && month <= tx.endMonth!);
    return afterStart && beforeEnd;
  }

  bool _isExcludedInMonth(int transactionId, int month, int year) {
    return _exclusions.any((ex) =>
        ex.transactionId == transactionId &&
        ex.month == month &&
        ex.year == year);
  }

  int _sumByType(List<Transaction> items, TransactionType type) {
    return items
        .where((tx) => tx.type == type)
        .fold(0, (sum, tx) => sum + tx.amountCents);
  }

  String _formatCurrency(int cents) {
    return 'R\$ ${formatMoney(cents)}';
  }

  int _computeSavingsCents() {
    final now = DateTime.now();
    int totalCents = 0;

    for (final tx in _allItems) {
      if (tx.isRecurring) {
        totalCents += _recurringContributionToSavings(tx, now);
      } else {
        final isUpToViewingMonth = _isOnOrBefore(
          tx.targetMonth, tx.targetYear, _currentMonth, _currentYear,
        );
        final isFutureIncome = tx.type == TransactionType.income &&
            !_isOnOrBefore(tx.targetMonth, tx.targetYear, now.month, now.year);

        if (isUpToViewingMonth && !isFutureIncome) {
          totalCents += _signedAmount(tx);
        }
      }
    }

    return totalCents;
  }

  int _recurringContributionToSavings(Transaction tx, DateTime now) {
    int totalCents = 0;
    int m = tx.targetMonth;
    int y = tx.targetYear;

    while (_isOnOrBefore(m, y, _currentMonth, _currentYear)) {
      if (tx.endMonth != null &&
          tx.endYear != null &&
          !_isOnOrBefore(m, y, tx.endMonth!, tx.endYear!)) {
        break;
      }

      final isFutureIncome = tx.type == TransactionType.income &&
          !_isOnOrBefore(m, y, now.month, now.year);

      if (!_isExcludedInMonth(tx.id, m, y) && !isFutureIncome) {
        totalCents += _signedAmount(tx);
      }

      if (m == 12) { m = 1; y++; } else { m++; }
    }

    return totalCents;
  }

  int _signedAmount(Transaction tx) {
    return tx.type == TransactionType.income
        ? tx.amountCents
        : -tx.amountCents;
  }

  bool _isOnOrBefore(int month, int year, int refMonth, int refYear) {
    return year < refYear || (year == refYear && month <= refMonth);
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

  void deleteItem(int id) {
    deleteTransaction.execute(id);
  }

  Future<void> deleteRecurringItem(
    Transaction transaction,
    RecurringDeleteMode mode,
  ) async {
    final result = await _deleteRecurringTransactionUseCase(
      transaction: transaction,
      mode: mode,
      currentMonth: _currentMonth,
      currentYear: _currentYear,
    );

    switch (result) {
      case Ok<int>():
        await _loadTransactions();
      case Error<int>():
        debugPrint('Erro ao deletar recorrente: ${result.error}');
    }
  }

  Transaction? findTransactionById(int id) {
    return _allItems.where((tx) => tx.id == id).firstOrNull;
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
