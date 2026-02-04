import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../domain/model/transaction_type.dart';
import '../../../l10n/app_localizations.dart';
import '../../viewmodel/transaction_form_viewmodel.dart';

/// Dialog para criar uma nova transação
class TransactionDialog extends StatelessWidget {
  final int selectedMonth;
  final int selectedYear;

  const TransactionDialog({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionFormViewModel>(
      builder: (context, viewModel, child) {
        final uiState = viewModel.uiState;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _TransactionTypeSelector(
                        selectedType: uiState.transactionType,
                        onTypeSelected: viewModel.onTransactionTypeChange,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                _CategoryAndQuantityInput(
                  uiState: uiState,
                  onExpenseCategoryChange:
                      viewModel.onExpenseCategoryChange,
                  onIncomeCategoryChange: viewModel.onIncomeCategoryChange,
                  onQuantityChange: viewModel.onQuantityChange,
                ),
                const SizedBox(height: 8),
                _NotesInput(
                  notes: uiState.notes,
                  onNotesChange: viewModel.onNotesChange,
                ),
                const SizedBox(height: 6),
                _ActionsBar(
                  isRecurring: uiState.isRecurring,
                  onRecurringChange: viewModel.onRecurringChange,
                  isSubmitEnabled: viewModel.isSubmitEnabled,
                  onSubmit: () async {
                    await viewModel.submit(selectedMonth, selectedYear);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TransactionTypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final void Function(TransactionType) onTypeSelected;

  const _TransactionTypeSelector({
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RadioOption(
          label: l10n.transactionTypeExpense,
          isSelected: selectedType == TransactionType.expense,
          onTap: () => onTypeSelected(TransactionType.expense),
        ),
        const SizedBox(width: 16),
        _RadioOption(
          label: l10n.transactionTypeIncome,
          isSelected: selectedType == TransactionType.income,
          onTap: () => onTypeSelected(TransactionType.income),
        ),
      ],
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RadioOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Radio<bool>(
            value: true,
            groupValue: isSelected,
            onChanged: (_) => onTap(),
          ),
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _CategoryAndQuantityInput extends StatelessWidget {
  final FormUiState uiState;
  final void Function(ExpenseCategory) onExpenseCategoryChange;
  final void Function(IncomeCategory) onIncomeCategoryChange;
  final void Function(String) onQuantityChange;

  const _CategoryAndQuantityInput({
    required this.uiState,
    required this.onExpenseCategoryChange,
    required this.onIncomeCategoryChange,
    required this.onQuantityChange,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _CategoryDropdown(
            transactionType: uiState.transactionType,
            expenseCategory: uiState.expenseCategory,
            incomeCategory: uiState.incomeCategory,
            onExpenseCategoryChange: onExpenseCategoryChange,
            onIncomeCategoryChange: onIncomeCategoryChange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: l10n.formQuantityLabel,
              border: const OutlineInputBorder(),
              errorText: uiState.isQuantityError
                  ? l10n.labelInvalidNumber
                  : null,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
            ],
            onChanged: onQuantityChange,
          ),
        ),
      ],
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final TransactionType transactionType;
  final ExpenseCategory? expenseCategory;
  final IncomeCategory? incomeCategory;
  final void Function(ExpenseCategory) onExpenseCategoryChange;
  final void Function(IncomeCategory) onIncomeCategoryChange;

  const _CategoryDropdown({
    required this.transactionType,
    required this.expenseCategory,
    required this.incomeCategory,
    required this.onExpenseCategoryChange,
    required this.onIncomeCategoryChange,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (transactionType == TransactionType.expense) {
      return DropdownButtonFormField<ExpenseCategory>(
        initialValue: expenseCategory,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: l10n.formCategoryLabel,
          border: const OutlineInputBorder(),
        ),
        selectedItemBuilder: (context) {
          return ExpenseCategory.values.map((category) {
            return Row(
              children: [
                Icon(_getExpenseCategoryIcon(category), size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _mapExpenseCategory(category, l10n),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }).toList();
        },
        items: ExpenseCategory.values.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Row(
              children: [
                Icon(_getExpenseCategoryIcon(category), size: 18),
                const SizedBox(width: 6),
                Text(_mapExpenseCategory(category, l10n)),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) onExpenseCategoryChange(value);
        },
      );
    } else {
      return DropdownButtonFormField<IncomeCategory>(
        initialValue: incomeCategory,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: l10n.formCategoryLabel,
          border: const OutlineInputBorder(),
        ),
        selectedItemBuilder: (context) {
          return IncomeCategory.values.map((category) {
            return Row(
              children: [
                Icon(_getIncomeCategoryIcon(category), size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _mapIncomeCategory(category, l10n),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }).toList();
        },
        items: IncomeCategory.values.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Row(
              children: [
                Icon(_getIncomeCategoryIcon(category), size: 18),
                const SizedBox(width: 6),
                Text(_mapIncomeCategory(category, l10n)),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) onIncomeCategoryChange(value);
        },
      );
    }
  }

  String _mapExpenseCategory(ExpenseCategory category, AppLocalizations l10n) {
    switch (category) {
      case ExpenseCategory.transport:
        return l10n.expenseCategoryTransport;
      case ExpenseCategory.gift:
        return l10n.expenseCategoryGift;
      case ExpenseCategory.recurring:
        return l10n.expenseCategoryRecurring;
      case ExpenseCategory.food:
        return l10n.expenseCategoryFood;
      case ExpenseCategory.stuff:
        return l10n.expenseCategoryStuff;
      case ExpenseCategory.medicine:
        return l10n.expenseCategoryMedicine;
      case ExpenseCategory.clothes:
        return l10n.expenseCategoryClothes;
    }
  }

  IconData _getExpenseCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.transport:
        return Icons.directions_car;
      case ExpenseCategory.gift:
        return Icons.card_giftcard;
      case ExpenseCategory.recurring:
        return Icons.repeat;
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.stuff:
        return Icons.shopping_bag;
      case ExpenseCategory.medicine:
        return Icons.medical_services;
      case ExpenseCategory.clothes:
        return Icons.checkroom;
    }
  }

  String _mapIncomeCategory(IncomeCategory category, AppLocalizations l10n) {
    switch (category) {
      case IncomeCategory.salary:
        return l10n.incomeCategorySalary;
      case IncomeCategory.gift:
        return l10n.incomeCategoryGift;
      case IncomeCategory.investment:
        return l10n.incomeCategoryInvestment;
      case IncomeCategory.other:
        return l10n.incomeCategoryOther;
    }
  }

  IconData _getIncomeCategoryIcon(IncomeCategory category) {
    switch (category) {
      case IncomeCategory.salary:
        return Icons.payments;
      case IncomeCategory.gift:
        return Icons.card_giftcard;
      case IncomeCategory.investment:
        return Icons.trending_up;
      case IncomeCategory.other:
        return Icons.attach_money;
    }
  }
}

class _NotesInput extends StatelessWidget {
  final String notes;
  final void Function(String) onNotesChange;

  const _NotesInput({required this.notes, required this.onNotesChange});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TextField(
      decoration: InputDecoration(
        labelText: l10n.formNotesLabel,
        border: const OutlineInputBorder(),
      ),
      onChanged: onNotesChange,
    );
  }
}

class _ActionsBar extends StatelessWidget {
  final bool isRecurring;
  final void Function(bool) onRecurringChange;
  final bool isSubmitEnabled;
  final VoidCallback onSubmit;

  const _ActionsBar({
    required this.isRecurring,
    required this.onRecurringChange,
    required this.isSubmitEnabled,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(l10n.formRecurringLabel),
            const SizedBox(width: 8),
            Switch(value: isRecurring, onChanged: onRecurringChange),
          ],
        ),
        ElevatedButton(
          onPressed: isSubmitEnabled ? onSubmit : null,
          child: Text(l10n.formSubmitButton),
        ),
      ],
    );
  }
}
