import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/main_screen_viewmodel.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/main_bottom_bar.dart';
import '../widgets/main_top_bar.dart';
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
                Column(
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
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: MainBottomBar(
                      onAddButtonClick: () => _showTransactionDialog(context, viewModel),
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
    await showDialog(
      context: context,
      builder: (context) => TransactionDialog(
        selectedMonth: viewModel.currentMonth,
        selectedYear: viewModel.currentYear,
      ),
    );
    viewModel.load.execute();
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
          onDelete: viewModel.deleteItem,
        );
      },
    );
  }
}
