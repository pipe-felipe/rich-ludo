import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/model/custom_category.dart';
import '../../../domain/model/transaction_type.dart';
import '../../../domain/usecase/create_custom_category_usecase.dart';
import '../../../domain/usecase/delete_custom_category_usecase.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/result.dart';
import '../../viewmodel/category_viewmodel.dart';
import '../theme/app_colors.dart';
import '../utils/category_icon.dart';

/// Creates and deletes the categories the user owns for one [TransactionType].
///
/// Deleting is refused while a transaction still carries the category, so a
/// stored transaction can never end up labelled with a category the user can
/// no longer see.
class CategoryManagerDialog extends StatefulWidget {
  final TransactionType transactionType;

  const CategoryManagerDialog({super.key, required this.transactionType});

  /// Returns the slug of the category created in this session, or `null` when
  /// the dialog was closed without creating one.
  static Future<String?> show(BuildContext context, TransactionType type) {
    return showDialog<String>(
      context: context,
      builder: (_) => CategoryManagerDialog(transactionType: type),
    );
  }

  @override
  State<CategoryManagerDialog> createState() => _CategoryManagerDialogState();
}

class _CategoryManagerDialogState extends State<CategoryManagerDialog> {
  final TextEditingController _nameController = TextEditingController();
  int _iconIndex = 0;
  int _colorIndex = 0;
  String? _formErrorText;
  String? _deleteErrorText;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final viewModel = context.watch<CategoryViewModel>();
    final categories = viewModel.categoriesFor(widget.transactionType);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.categoryManagerTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                maxLength: CreateCustomCategoryUseCase.maxNameLength,
                decoration: InputDecoration(
                  labelText: l10n.categoryNameLabel,
                  border: const OutlineInputBorder(),
                  errorText: _formErrorText,
                ),
              ),
              Text(l10n.categoryIconLabel, style: theme.textTheme.labelMedium),
              const SizedBox(height: 6),
              _IconPicker(
                selectedIndex: _iconIndex,
                onSelected: (index) => setState(() => _iconIndex = index),
              ),
              const SizedBox(height: 12),
              Text(l10n.categoryColorLabel, style: theme.textTheme.labelMedium),
              const SizedBox(height: 6),
              _ColorPicker(
                selectedIndex: _colorIndex,
                onSelected: (index) => setState(() => _colorIndex = index),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton.tonal(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.formCloseButtonDescription),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _onSave(viewModel, l10n),
                    child: Text(l10n.categorySave),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                l10n.categoryMineTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              if (categories.isEmpty)
                Text(l10n.categoryEmpty, style: theme.textTheme.bodyMedium)
              else
                ...categories.map(
                  (category) => _CategoryRow(
                    category: category,
                    onDelete: () => _onDelete(viewModel, category, l10n),
                  ),
                ),
              if (_deleteErrorText != null) ...[
                const SizedBox(height: 8),
                Text(
                  _deleteErrorText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSave(
    CategoryViewModel viewModel,
    AppLocalizations l10n,
  ) async {
    final draft = CustomCategory.draft(
      name: _nameController.text,
      type: widget.transactionType,
      iconCodePoint: customCategoryIcons[_iconIndex].codePoint,
      colorValue: CategoryPiColors.customPalette[_colorIndex].toARGB32(),
    );

    await viewModel.create.execute(draft);

    if (!mounted) return;

    final result = viewModel.create.result;
    if (result == null) return;

    switch (result) {
      case Ok<int>():
        Navigator.of(context).pop(draft.slug);
      case Error<int>(:final error):
        setState(() => _formErrorText = _createErrorText(error, l10n));
    }
  }

  Future<void> _onDelete(
    CategoryViewModel viewModel,
    CustomCategory category,
    AppLocalizations l10n,
  ) async {
    await viewModel.delete.execute(category);

    if (!mounted) return;

    final result = viewModel.delete.result;
    setState(() {
      _deleteErrorText = switch (result) {
        Error<int>(:final error) when error is CategoryInUseException =>
          l10n.categoryDeleteInUse(error.transactionCount),
        Error<int>() => l10n.categoryErrorSaveFailed,
        _ => null,
      };
    });
  }

  String _createErrorText(Exception error, AppLocalizations l10n) {
    if (error is! CategoryValidationException) {
      return l10n.categoryErrorSaveFailed;
    }

    return switch (error.reason) {
      CategoryValidationError.emptyName => l10n.categoryErrorEmptyName,
      CategoryValidationError.nameTooLong => l10n.categoryErrorNameTooLong,
      CategoryValidationError.duplicateName => l10n.categoryErrorDuplicateName,
    };
  }
}

class _IconPicker extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onSelected;

  const _IconPicker({required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(customCategoryIcons.length, (index) {
        final isSelected = index == selectedIndex;

        return InkWell(
          onTap: () => onSelected(index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer
                  : Colors.transparent,
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(customCategoryIcons[index], size: 20),
          ),
        );
      }),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onSelected;

  const _ColorPicker({required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(CategoryPiColors.customPalette.length, (index) {
        final isSelected = index == selectedIndex;

        return InkWell(
          onTap: () => onSelected(index),
          customBorder: const CircleBorder(),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: CategoryPiColors.customPalette[index],
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? colorScheme.onSurface : Colors.transparent,
                width: 3,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final CustomCategory category;
  final VoidCallback onDelete;

  const _CategoryRow({required this.category, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Icon(
          resolveCustomCategoryIcon(category.iconCodePoint),
          size: 20,
          color: Color(category.colorValue),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(category.name, overflow: TextOverflow.ellipsis)),
        IconButton(
          onPressed: onDelete,
          tooltip: l10n.categoryDeleteTooltip,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}
