import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/model/custom_category.dart';
import '../../../domain/model/transaction.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/result.dart';
import '../../viewmodel/category_viewmodel.dart';
import '../../viewmodel/main_screen_viewmodel.dart';
import '../../viewmodel/transaction_form_viewmodel.dart';
import 'chart_screen.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/floating_notification.dart';
import '../widgets/main_bottom_bar.dart';
import '../widgets/main_top_bar.dart';
import '../widgets/recurring_scope_dialog.dart';
import '../widgets/transaction_dialog.dart';
import '../widgets/transaction_list.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainScreenViewModel>(
      builder: (context, viewModel, child) {
        final isPortrait =
            MediaQuery.orientationOf(context) == Orientation.portrait;
        final currentMonthYear = _formatMonthYear(
          context,
          viewModel.currentMonth,
          viewModel.currentYear,
        );
        final customCategories = context.watch<CategoryViewModel>().categories;
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                GestureDetector(
                  onHorizontalDragEnd: (details) {
                    final velocity = details.primaryVelocity ?? 0;
                    if (velocity > 0) {
                      viewModel.goToPreviousMonth();
                    } else if (velocity < 0) {
                      viewModel.goToNextMonth();
                    }
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Column(
                    children: [
                      if (isPortrait)
                        MainTopBar(
                          totalIncomeText: viewModel.totalIncomeText,
                          totalExpenseText: viewModel.totalExpenseText,
                          totalSavingText: viewModel.totalSavingText,
                          totalIncomeCents: viewModel.totalIncomeCents,
                          totalExpenseCents: viewModel.totalExpenseCents,
                          currentMonthYear: currentMonthYear,
                          onPreviousMonth: viewModel.goToPreviousMonth,
                          onNextMonth: viewModel.goToNextMonth,
                          onCurrentMonthClick: viewModel.goToCurrentMonth,
                        ),
                      Expanded(
                        child: isPortrait
                            ? _TransactionContent(
                                viewModel: viewModel,
                                customCategories: customCategories,
                              )
                            : _ChartContent(
                                viewModel: viewModel,
                                currentMonthYear: currentMonthYear,
                                customCategories: customCategories,
                              ),
                      ),
                    ],
                  ),
                ),
                if (isPortrait)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: MainBottomBar(
                        onAddButtonClick: () =>
                            _showTransactionDialog(context, viewModel),
                        onRecoveryClick: () =>
                            _importDatabase(context, viewModel),
                        onSaveClick: () => _exportDatabase(context, viewModel),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatMonthYear(BuildContext context, int month, int year) {
    final l10n = AppLocalizations.of(context)!;
    final monthNames = [
      l10n.january,
      l10n.february,
      l10n.march,
      l10n.april,
      l10n.may,
      l10n.june,
      l10n.july,
      l10n.august,
      l10n.september,
      l10n.october,
      l10n.november,
      l10n.december,
    ];
    return '${monthNames[month - 1]} $year';
  }

  Future<void> _showTransactionDialog(
    BuildContext context,
    MainScreenViewModel viewModel,
  ) async {
    final formViewModel = context.read<TransactionFormViewModel>();
    formViewModel.resetForm();

    await showDialog(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: formViewModel,
        child: TransactionDialog(
          selectedMonth: viewModel.currentMonth,
          selectedYear: viewModel.currentYear,
        ),
      ),
    );
    viewModel.invalidateAndReload();
  }

  Future<void> _exportDatabase(
    BuildContext context,
    MainScreenViewModel viewModel,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    await viewModel.exportDatabase.execute();

    final result = viewModel.exportDatabase.result;
    if (result == null) return;

    if (!context.mounted) return;

    switch (result) {
      case Ok<String>():
        showFloatingNotification(
          context: context,
          message: l10n.exportSuccess,
          type: NotificationType.success,
        );
      case Error<String>(:final error):
        // Do not show an error if the user simply cancelled
        final errorMsg = error.toString();
        if (!errorMsg.contains('cancelled')) {
          showFloatingNotification(
            context: context,
            message: '${l10n.exportError}: $errorMsg',
            type: NotificationType.error,
            duration: const Duration(seconds: 5),
          );
        }
    }
  }

  Future<void> _importDatabase(
    BuildContext context,
    MainScreenViewModel viewModel,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    await viewModel.importDatabase.execute();

    final result = viewModel.importDatabase.result;
    if (result == null) return;

    if (!context.mounted) return;

    switch (result) {
      case Ok<void>():
        showFloatingNotification(
          context: context,
          message: l10n.importSuccess,
          type: NotificationType.success,
        );
        // Reload data after importing
        viewModel.invalidateAndReload();
      case Error<void>(:final error):
        // Do not show an error if the user simply cancelled
        final errorMsg = error.toString();
        if (!errorMsg.contains('cancelled')) {
          showFloatingNotification(
            context: context,
            message: '${l10n.importError}: $errorMsg',
            type: NotificationType.error,
            duration: const Duration(seconds: 5),
          );
        }
    }
  }
}

class _TransactionContent extends StatelessWidget {
  final MainScreenViewModel viewModel;
  final List<CustomCategory> customCategories;

  const _TransactionContent({
    required this.viewModel,
    required this.customCategories,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel.load,
      builder: (context, _) {
        if (viewModel.load.running) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.load.error) {
          return ErrorState(onRetry: viewModel.load.execute);
        }

        if (viewModel.items.isEmpty) {
          return const EmptyState();
        }

        return TransactionList(
          items: viewModel.items,
          customCategories: customCategories,
          onDelete: (transaction) => _handleDelete(context, transaction),
        );
      },
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    Transaction transaction,
  ) async {
    if (transaction.isRecurring) {
      final mode = await RecurringScopeDialog.show(
        context,
        title: AppLocalizations.of(context)!.recurringDeleteTitle,
      );
      if (mode != null) {
        await viewModel.deleteRecurringItem(transaction, mode);
      }
    } else {
      viewModel.deleteItem(transaction.id);
    }
  }
}

class _ChartContent extends StatelessWidget {
  final MainScreenViewModel viewModel;
  final String currentMonthYear;
  final List<CustomCategory> customCategories;

  const _ChartContent({
    required this.viewModel,
    required this.currentMonthYear,
    required this.customCategories,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel.load,
      builder: (context, _) {
        if (viewModel.load.running) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.load.error) {
          return ErrorState(onRetry: viewModel.load.execute);
        }

        if (viewModel.expenseByCategory.isEmpty) {
          return const EmptyState();
        }

        return ChartScreen(
          categoryTotals: viewModel.expenseByCategory,
          totalExpenseCents: viewModel.totalExpenseCents,
          customCategories: customCategories,
          totalExpenseText: viewModel.totalExpenseText,
          currentMonthYear: currentMonthYear,
          onPreviousMonth: viewModel.goToPreviousMonth,
          onNextMonth: viewModel.goToNextMonth,
          onCurrentMonthClick: viewModel.goToCurrentMonth,
        );
      },
    );
  }
}
