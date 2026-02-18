import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../domain/model/transaction_type.dart';
import '../../../l10n/app_localizations.dart';
import '../../viewmodel/transaction_form_viewmodel.dart';
import '../utils/category_icon.dart';
import '../utils/category_mapper.dart';

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
          insetPadding: const EdgeInsets.symmetric(horizontal: 25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 0,
              bottom: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 56,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Transform.translate(
                          offset: Offset(-15, -4),
                          child: _TransactionTypeSelector(
                            selectedType: uiState.transactionType,
                            onTypeSelected: viewModel.onTransactionTypeChange,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -1,
                        right: -15,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ),
                    ],
                  ),
                ),
                _CategoryAndQuantityInput(
                  uiState: uiState,
                  onExpenseCategoryChange: viewModel.onExpenseCategoryChange,
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

    return RadioGroup<TransactionType>(
      groupValue: selectedType,
      onChanged: (value) {
        if (value != null) onTypeSelected(value);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _RadioOption(
            label: l10n.transactionTypeExpense,
            value: TransactionType.expense,
            onTap: () => onTypeSelected(TransactionType.expense),
          ),
          const SizedBox(width: 16),
          _RadioOption(
            label: l10n.transactionTypeIncome,
            value: TransactionType.income,
            onTap: () => onTypeSelected(TransactionType.income),
          ),
        ],
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final TransactionType value;
  final VoidCallback onTap;

  const _RadioOption({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Radio<TransactionType>(value: value),
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
                Icon(getCategoryIcon(category.name, isIncome: false), size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    mapExpenseCategory(category, l10n),
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
                Icon(getCategoryIcon(category.name, isIncome: false), size: 18),
                const SizedBox(width: 6),
                Text(mapExpenseCategory(category, l10n)),
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
                Icon(getCategoryIcon(category.name, isIncome: true), size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    mapIncomeCategory(category, l10n),
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
                Icon(getCategoryIcon(category.name, isIncome: true), size: 18),
                const SizedBox(width: 6),
                Text(mapIncomeCategory(category, l10n)),
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
