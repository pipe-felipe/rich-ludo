import 'package:flutter/foundation.dart';
import '../../domain/model/recurring_exclusion.dart';
import '../../domain/model/transaction.dart';
import '../../domain/model/transaction_type.dart';
import '../../domain/usecase/delete_recurring_transaction_usecase.dart';
import '../../domain/usecase/delete_transaction_usecase.dart';
import '../../domain/usecase/export_database_usecase.dart';
import '../../domain/usecase/get_exclusions_usecase.dart';
import '../../domain/usecase/get_transactions_by_month_year_usecase.dart';
import '../../domain/usecase/get_non_recurring_balance_usecase.dart';
import '../../domain/usecase/import_database_usecase.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';
import '../ui/utils/money_formatter.dart';

class MainScreenViewModel extends ChangeNotifier {
  final GetTransactionsByMonthYearUseCase _getTransactionsUseCase;
  final GetNonRecurringBalanceUseCase _getNonRecurringBalanceUseCase;
  final DeleteTransactionUseCase _deleteTransactionUseCase;
  final DeleteRecurringTransactionUseCase _deleteRecurringTransactionUseCase;
  final GetExclusionsUseCase _getExclusionsUseCase;
  final ExportDatabaseUseCase _exportDatabaseUseCase;
  final ImportDatabaseUseCase _importDatabaseUseCase;

  final Map<String, List<Transaction>> _cachedMonths = {};
  int _nonRecurringBalance = 0;
  List<RecurringExclusion> _exclusions = [];
  List<Transaction> _items = [];
  String _totalIncomeText = 'R\$ 0.00';
  String _totalExpenseText = 'R\$ 0.00';
  String _totalSavingText = 'R\$ 0.00';
  int _totalIncomeCents = 0;
  int _totalExpenseCents = 0;
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;
  bool _needsReload = false;

  late final Command0<List<Transaction>> load;

  late final Command1<int, int> deleteTransaction;

  late final Command0<String> exportDatabase;

  late final Command0<void> importDatabase;

  MainScreenViewModel({
    required GetTransactionsByMonthYearUseCase getTransactionsUseCase,
    required GetNonRecurringBalanceUseCase getNonRecurringBalanceUseCase,
    required DeleteTransactionUseCase deleteTransactionUseCase,
    required DeleteRecurringTransactionUseCase
    deleteRecurringTransactionUseCase,
    required GetExclusionsUseCase getExclusionsUseCase,
    required ExportDatabaseUseCase exportDatabaseUseCase,
    required ImportDatabaseUseCase importDatabaseUseCase,
  }) : _getTransactionsUseCase = getTransactionsUseCase,
       _getNonRecurringBalanceUseCase = getNonRecurringBalanceUseCase,
       _deleteTransactionUseCase = deleteTransactionUseCase,
       _deleteRecurringTransactionUseCase = deleteRecurringTransactionUseCase,
       _getExclusionsUseCase = getExclusionsUseCase,
       _exportDatabaseUseCase = exportDatabaseUseCase,
       _importDatabaseUseCase = importDatabaseUseCase {
    load = Command0<List<Transaction>>(_loadTransactions);
    load.addListener(_onLoadChanged);
    deleteTransaction = Command1<int, int>(_deleteItem);
    exportDatabase = Command0<String>(_exportDatabaseUseCase.call);
    importDatabase = Command0<void>(_importDatabaseUseCase.call);

    load.execute();
  }

  @override
  void dispose() {
    load.removeListener(_onLoadChanged);
    super.dispose();
  }

  List<Transaction> get items => _items;
  String get totalIncomeText => _totalIncomeText;
  String get totalExpenseText => _totalExpenseText;
  String get totalSavingText => _totalSavingText;
  int get totalIncomeCents => _totalIncomeCents;
  int get totalExpenseCents => _totalExpenseCents;
  int get currentMonth => _currentMonth;
  int get currentYear => _currentYear;

  void _onLoadChanged() {
    if (!load.running && _needsReload) {
      _needsReload = false;
      load.execute();
    }
  }

  void _requestLoad() {
    if (load.running) {
      _needsReload = true;
    } else {
      _needsReload = false;
      load.execute();
    }
  }

  Future<Result<List<Transaction>>> _loadTransactions() async {
    final month = _currentMonth;
    final year = _currentYear;
    final cacheKey = '$month-$year';

    if (_cachedMonths.containsKey(cacheKey)) {
      _items = _cachedMonths[cacheKey]!;
      final exclusionsResult = await _getExclusionsUseCase();
      if (exclusionsResult case Ok<List<RecurringExclusion>>(:final value)) {
        _exclusions = value;
      }

      final balanceResult = await _getNonRecurringBalanceUseCase(
        upToMonth: month,
        upToYear: year,
      );
      if (balanceResult case Ok<int>(:final value)) {
        _nonRecurringBalance = value;
      }

      if (month == _currentMonth && year == _currentYear) {
        _filterAndComputeTotals();
      }
      return Result.ok(_items);
    }

    final results = await Future.wait([
      _getTransactionsUseCase(month: month, year: year),
      _getExclusionsUseCase(),
      _getNonRecurringBalanceUseCase(upToMonth: month, upToYear: year),
    ]);

    final result = results[0] as Result<List<Transaction>>;
    final exclusionsResult = results[1] as Result<List<RecurringExclusion>>;
    final balanceResult = results[2] as Result<int>;

    switch (result) {
      case Ok<List<Transaction>>(:final value):
        _cachedMonths[cacheKey] = value;
      case Error<List<Transaction>>():
        debugPrint('Error loading transactions: ${result.error}');
    }

    switch (exclusionsResult) {
      case Ok<List<RecurringExclusion>>(:final value):
        _exclusions = value;
      case Error<List<RecurringExclusion>>():
        debugPrint('Error loading exclusions: ${exclusionsResult.error}');
    }

    switch (balanceResult) {
      case Ok<int>(:final value):
        _nonRecurringBalance = value;
      case Error<int>():
        debugPrint('Error loading balance: ${balanceResult.error}');
    }

    if (month == _currentMonth && year == _currentYear) {
      _filterAndComputeTotals();
    }
    return result;
  }

  void _invalidateCache() {
    _cachedMonths.clear();
  }

  void invalidateAndReload() {
    _invalidateCache();
    _requestLoad();
  }

  Future<Result<int>> _deleteItem(int id) async {
    final result = await _deleteTransactionUseCase(id);

    switch (result) {
      case Ok<int>():
        break;
      case Error<int>():
        debugPrint('Error deleting item: ${result.error}');
    }

    return result;
  }

  void _filterAndComputeTotals() {
    _items = _visibleItemsForMonth(_currentMonth, _currentYear);
    _totalIncomeCents = _sumByType(_items, TransactionType.income);
    _totalExpenseCents = _sumByType(_items, TransactionType.expense);
    _totalIncomeText = _formatCurrency(_totalIncomeCents);
    _totalExpenseText = _formatCurrency(_totalExpenseCents);
    _totalSavingText = _formatCurrency(_computeSavingsCents());
    notifyListeners();
  }

  List<Transaction> _visibleItemsForMonth(int month, int year) {
    final cacheKey = '$month-$year';
    final monthItems = _cachedMonths[cacheKey] ?? [];

    return monthItems.where((tx) {
      if (tx.isRecurring) {
        return _isRecurringActiveInMonth(tx, month, year) &&
            !_isExcludedInMonth(tx.id, month, year);
      }
      return tx.targetMonth == month && tx.targetYear == year;
    }).toList();
  }

  bool _isRecurringActiveInMonth(Transaction tx, int month, int year) {
    final afterStart =
        tx.targetYear < year ||
        (tx.targetYear == year && tx.targetMonth <= month);
    final beforeEnd =
        tx.endMonth == null ||
        tx.endYear == null ||
        year < tx.endYear! ||
        (year == tx.endYear! && month <= tx.endMonth!);
    return afterStart && beforeEnd;
  }

  bool _isExcludedInMonth(int transactionId, int month, int year) {
    return _exclusions.any(
      (ex) =>
          ex.transactionId == transactionId &&
          ex.month == month &&
          ex.year == year,
    );
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
    final refMonth = now.month;
    final refYear = now.year;

    // Start with the past accumulated non-recurring balance
    int totalCents = _nonRecurringBalance;

    // Collect all unique recurring transactions available in the current fetched content.
    // Notice: global recurring txs are returned in any getTransactionsUseCase call.
    final cacheKey = '$_currentMonth-$_currentYear';
    final monthItems = _cachedMonths[cacheKey] ?? [];

    for (final tx in monthItems) {
      if (tx.isRecurring) {
        totalCents += _recurringContributionToSavings(
          tx,
          now,
          refMonth,
          refYear,
        );
      }
    }

    return totalCents;
  }

  int _recurringContributionToSavings(
    Transaction tx,
    DateTime now,
    int refMonth,
    int refYear,
  ) {
    int totalCents = 0;
    int m = tx.targetMonth;
    int y = tx.targetYear;

    while (_isOnOrBefore(m, y, refMonth, refYear)) {
      if (tx.endMonth != null &&
          tx.endYear != null &&
          !_isOnOrBefore(m, y, tx.endMonth!, tx.endYear!)) {
        break;
      }

      final isFutureIncome =
          tx.type == TransactionType.income &&
          !_isOnOrBefore(m, y, now.month, now.year);

      if (!_isExcludedInMonth(tx.id, m, y) && !isFutureIncome) {
        totalCents += _signedAmount(tx);
      }

      if (m == 12) {
        m = 1;
        y++;
      } else {
        m++;
      }
    }

    return totalCents;
  }

  int _signedAmount(Transaction tx) {
    return tx.type == TransactionType.income ? tx.amountCents : -tx.amountCents;
  }

  bool _isOnOrBefore(int month, int year, int refMonth, int refYear) {
    return year < refYear || (year == refYear && month <= refMonth);
  }

  Future<void> deleteItem(int id) async {
    await deleteTransaction.execute(id);
    if (deleteTransaction.completed) {
      invalidateAndReload();
    }
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
        invalidateAndReload();
      case Error<int>():
        debugPrint('Error deleting recurring: ${result.error}');
    }
  }

  Transaction? findTransactionById(int id) {
    for (final monthTxs in _cachedMonths.values) {
      final found = monthTxs.where((tx) => tx.id == id).firstOrNull;
      if (found != null) return found;
    }
    return null;
  }

  void goToPreviousMonth() {
    if (_currentMonth == 1) {
      _currentMonth = 12;
      _currentYear--;
    } else {
      _currentMonth--;
    }
    notifyListeners();
    _requestLoad();
  }

  void goToNextMonth() {
    if (_currentMonth == 12) {
      _currentMonth = 1;
      _currentYear++;
    } else {
      _currentMonth++;
    }
    notifyListeners();
    _requestLoad();
  }

  void goToCurrentMonth() {
    final now = DateTime.now();
    _currentMonth = now.month;
    _currentYear = now.year;
    notifyListeners();
    _requestLoad();
  }
}
