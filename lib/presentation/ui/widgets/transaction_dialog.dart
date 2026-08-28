import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../domain/model/custom_category.dart';
import '../../../domain/model/transaction.dart';
import '../../../domain/model/transaction_type.dart';
import '../../../l10n/app_localizations.dart';
import '../../viewmodel/category_viewmodel.dart';
import '../../viewmodel/transaction_form_viewmodel.dart';
import '../utils/category_icon.dart';
import '../utils/category_mapper.dart';
import 'category_manager_dialog.dart';

/// Value of the dropdown entry that opens [CategoryManagerDialog]. It is never
/// stored: `_CategoryDropdown` turns it into a dialog instead of a selection.
const String _newCategoryOptionValue = '__new_category__';

class TransactionDialog extends StatelessWidget {
  final int selectedMonth;
  final int selectedYear;

  /// Called instead of the create path when the form is editing a stored
  /// transaction. Returns true when the edit was applied and the dialog may
  /// close, false when the user backed out of the scope dialog.
  final Future<bool> Function(Transaction edited)? onSubmitEdit;

  const TransactionDialog({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    this.onSubmitEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionFormViewModel>(
      builder: (context, viewModel, child) {
        final uiState = viewModel.uiState;
        final customCategories = context
            .watch<CategoryViewModel>()
            .categoriesFor(uiState.transactionType);

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
                  customCategories: customCategories,
                  onCategoryChange: viewModel.onCategoryChange,
                  onQuantityChange: viewModel.onQuantityChange,
                ),
                const SizedBox(height: 8),
                _NotesInput(
                  initialNotes: uiState.notes,
                  onNotesChange: viewModel.onNotesChange,
                ),
                const SizedBox(height: 6),
                _ActionsBar(
                  isRecurring: uiState.isRecurring,
                  onRecurringChange: viewModel.onRecurringChange,
                  isSubmitEnabled: viewModel.isSubmitEnabled,
                  onSubmit: () async {
                    if (viewModel.isEditing) {
                      final edited = viewModel.buildEditedTransaction();
                      if (edited == null) return;
                      final applied = await onSubmitEdit?.call(edited) ?? false;
                      if (!applied) return;
                    } else {
                      await viewModel.submit(selectedMonth, selectedYear);
                    }
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
  final List<CustomCategory> customCategories;
  final void Function(String) onCategoryChange;
  final void Function(String) onQuantityChange;

  const _CategoryAndQuantityInput({
    required this.uiState,
    required this.customCategories,
    required this.onCategoryChange,
    required this.onQuantityChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _CategoryDropdown(
            transactionType: uiState.transactionType,
            customCategories: customCategories,
            categorySlug: uiState.categorySlug,
            onCategoryChange: onCategoryChange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuantityInput(
            initialQuantity: uiState.quantity,
            isQuantityError: uiState.isQuantityError,
            onQuantityChange: onQuantityChange,
          ),
        ),
      ],
    );
  }
}

class _QuantityInput extends StatefulWidget {
  final String initialQuantity;
  final bool isQuantityError;
  final void Function(String) onQuantityChange;

  const _QuantityInput({
    required this.initialQuantity,
    required this.isQuantityError,
    required this.onQuantityChange,
  });

  @override
  State<_QuantityInput> createState() => _QuantityInputState();
}

class _QuantityInputState extends State<_QuantityInput> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialQuantity,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: l10n.formQuantityLabel,
        border: const OutlineInputBorder(),
        errorText: widget.isQuantityError ? l10n.labelInvalidNumber : null,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
      onChanged: widget.onQuantityChange,
    );
  }
}

/// One entry of the category dropdown: the value stored in
/// `transactions.category`, the text shown, and the icon shown beside it.
class _CategoryOption {
  final String slug;
  final String label;
  final IconData icon;

  const _CategoryOption({
    required this.slug,
    required this.label,
    required this.icon,
  });
}

List<_CategoryOption> _builtInOptions(
  TransactionType type,
  AppLocalizations l10n,
) {
  if (type == TransactionType.expense) {
    return ExpenseCategory.values
        .map(
          (category) => _CategoryOption(
            slug: category.name,
            label: mapExpenseCategory(category, l10n),
            icon: category.icon,
          ),
        )
        .toList();
  }

  return IncomeCategory.values
      .map(
        (category) => _CategoryOption(
          slug: category.name,
          label: mapIncomeCategory(category, l10n),
          icon: category.icon,
        ),
      )
      .toList();
}

List<_CategoryOption> _customOptions(List<CustomCategory> categories) {
  return categories
      .map(
        (category) => _CategoryOption(
          slug: category.slug,
          label: category.name,
          icon: resolveCustomCategoryIcon(category.iconCodePoint),
        ),
      )
      .toList();
}

class _CategoryDropdown extends StatefulWidget {
  final TransactionType transactionType;
  final List<CustomCategory> customCategories;
  final String? categorySlug;
  final void Function(String) onCategoryChange;

  const _CategoryDropdown({
    required this.transactionType,
    required this.customCategories,
    required this.categorySlug,
    required this.onCategoryChange,
  });

  @override
  State<_CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<_CategoryDropdown> {
  // Picking the "new category" entry leaves that entry showing inside the
  // form field, because DropdownButtonFormField keeps its own selection.
  // Bumping this token changes the field's key, which rebuilds it from
  // `initialValue` and drops the entry that was never a real choice.
  int _resetToken = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      ..._builtInOptions(widget.transactionType, l10n),
      ..._customOptions(widget.customCategories),
      _CategoryOption(
        slug: _newCategoryOptionValue,
        label: l10n.categoryCreateNew,
        icon: Icons.add,
      ),
    ];
    // A slug that is not among the options would trip the dropdown's own
    // assertion, so an unknown or deleted one shows as nothing chosen.
    final selected =
        widget.categorySlug != _newCategoryOptionValue &&
            options.any((option) => option.slug == widget.categorySlug)
        ? widget.categorySlug
        : null;

    return DropdownButtonFormField<String>(
      key: ValueKey('$selected-$_resetToken'),
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.formCategoryLabel,
        border: const OutlineInputBorder(),
      ),
      selectedItemBuilder: (context) {
        return options.map((option) {
          return Row(
            children: [
              Icon(option.icon, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(option.label, overflow: TextOverflow.ellipsis),
              ),
            ],
          );
        }).toList();
      },
      items: options.map((option) {
        return DropdownMenuItem(
          value: option.slug,
          child: Row(
            children: [
              Icon(option.icon, size: 18),
              const SizedBox(width: 6),
              Text(option.label),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) async {
        if (value == null) return;

        if (value != _newCategoryOptionValue) {
          widget.onCategoryChange(value);
          return;
        }

        final createdSlug = await CategoryManagerDialog.show(
          context,
          widget.transactionType,
        );

        if (createdSlug != null) {
          widget.onCategoryChange(createdSlug);
        }
        if (mounted) {
          setState(() => _resetToken++);
        }
      },
    );
  }
}

class _NotesInput extends StatefulWidget {
  final String initialNotes;
  final void Function(String) onNotesChange;

  const _NotesInput({required this.initialNotes, required this.onNotesChange});

  @override
  State<_NotesInput> createState() => _NotesInputState();
}

class _NotesInputState extends State<_NotesInput> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialNotes,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: l10n.formNotesLabel,
        border: const OutlineInputBorder(),
      ),
      onChanged: widget.onNotesChange,
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
