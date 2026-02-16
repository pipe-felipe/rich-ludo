import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/model/transaction.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/result.dart';
import '../../viewmodel/main_screen_viewmodel.dart';
import '../../viewmodel/transaction_form_viewmodel.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/floating_notification.dart';
import '../widgets/main_bottom_bar.dart';
import '../widgets/main_top_bar.dart';
import '../widgets/recurring_delete_dialog.dart';
import '../widgets/transaction_dialog.dart';
import '../widgets/transaction_list.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainScreenViewModel>(
      builder: (context, viewModel, child) {
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
                      MainTopBar(
                        totalIncomeText: viewModel.totalIncomeText,
                        totalExpenseText: viewModel.totalExpenseText,
                        totalSavingText: viewModel.totalSavingText,
                        currentMonthYear: viewModel.currentMonthYearText,
                        onPreviousMonth: viewModel.goToPreviousMonth,
                        onNextMonth: viewModel.goToNextMonth,
                        onCurrentMonthClick: viewModel.goToCurrentMonth,
                      ),
                      Expanded(
                        child: _TransactionContent(viewModel: viewModel),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: MainBottomBar(
                      onAddButtonClick: () => _showTransactionDialog(context, viewModel),
                      onRecoveryClick: () => _importDatabase(context, viewModel),
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
    viewModel.load.execute();
  }

  Future<void> _exportDatabase(
    BuildContext context,
    MainScreenViewModel viewModel,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    
    await viewModel.exportDatabase.execute();
    
    final result = viewModel.exportDatabase.result;
    if (result == null) return;

    // Garantir que o contexto ainda é válido antes de mostrar notificação
    if (!context.mounted) return;

    switch (result) {
      case Ok<String>():
        showFloatingNotification(
          context: context,
          message: l10n.exportSuccess,
          type: NotificationType.success,
        );
      case Error<String>(:final error):
        // Não mostrar erro se o usuário apenas cancelou
        final errorMsg = error.toString();
        if (!errorMsg.contains('cancelada')) {
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

    // Garantir que o contexto ainda é válido antes de mostrar notificação
    if (!context.mounted) return;

    switch (result) {
      case Ok<void>():
        showFloatingNotification(
          context: context,
          message: l10n.importSuccess,
          type: NotificationType.success,
        );
        // Recarregar dados após importar
        viewModel.load.execute();
      case Error<void>(:final error):
        // Não mostrar erro se o usuário apenas cancelou
        final errorMsg = error.toString();
        if (!errorMsg.contains('cancelada')) {
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

  const _TransactionContent({required this.viewModel});

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
          onDelete: (transaction) => _handleDelete(context, transaction),
        );
      },
    );
  }

  Future<void> _handleDelete(BuildContext context, Transaction transaction) async {
    if (transaction.isRecurring) {
      final mode = await RecurringDeleteDialog.show(context);
      if (mode != null) {
        await viewModel.deleteRecurringItem(transaction, mode);
      }
    } else {
      viewModel.deleteItem(transaction.id);
    }
  }
}
