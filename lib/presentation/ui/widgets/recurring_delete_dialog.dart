import 'package:flutter/material.dart';
import '../../../domain/usecase/delete_recurring_transaction_usecase.dart';
import '../../../l10n/app_localizations.dart';

class RecurringDeleteDialog extends StatelessWidget {
  const RecurringDeleteDialog({super.key});

  static Future<RecurringDeleteMode?> show(BuildContext context) {
    return showDialog<RecurringDeleteMode>(
      context: context,
      builder: (_) => const RecurringDeleteDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.recurringDeleteTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DialogOption(
            icon: Icons.today,
            label: l10n.recurringDeleteThisMonth,
            onTap: () =>
                Navigator.of(context).pop(RecurringDeleteMode.thisMonth),
          ),
          const SizedBox(height: 8),
          _DialogOption(
            icon: Icons.arrow_back,
            label: l10n.recurringDeleteBackwards,
            onTap: () => Navigator.of(
              context,
            ).pop(RecurringDeleteMode.thisAndPreviousMonths),
          ),
          const SizedBox(height: 8),
          _DialogOption(
            icon: Icons.arrow_forward,
            label: l10n.recurringDeleteForwards,
            onTap: () => Navigator.of(
              context,
            ).pop(RecurringDeleteMode.thisAndFutureMonths),
          ),
          const SizedBox(height: 8),
          _DialogOption(
            icon: Icons.delete_forever,
            label: l10n.recurringDeleteAll,
            onTap: () =>
                Navigator.of(context).pop(RecurringDeleteMode.allMonths),
            isDestructive: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.formCloseButtonDescription),
        ),
      ],
    );
  }
}

class _DialogOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DialogOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
