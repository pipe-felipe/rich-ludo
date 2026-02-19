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

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.recurringDeleteTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _DialogPillOption(
              icon: Icons.today,
              label: l10n.recurringDeleteThisMonth,
              onTap: () =>
                  Navigator.of(context).pop(RecurringDeleteMode.thisMonth),
            ),
            const SizedBox(height: 10),
            _DialogPillOption(
              icon: Icons.arrow_back,
              label: l10n.recurringDeleteBackwards,
              onTap: () => Navigator.of(
                context,
              ).pop(RecurringDeleteMode.thisAndPreviousMonths),
            ),
            const SizedBox(height: 10),
            _DialogPillOption(
              icon: Icons.arrow_forward,
              label: l10n.recurringDeleteForwards,
              onTap: () => Navigator.of(
                context,
              ).pop(RecurringDeleteMode.thisAndFutureMonths),
            ),
            const SizedBox(height: 10),
            _DialogPillOption(
              icon: Icons.delete_forever,
              label: l10n.recurringDeleteAll,
              onTap: () =>
                  Navigator.of(context).pop(RecurringDeleteMode.allMonths),
              isDestructive: true,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.formCloseButtonDescription),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogPillOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DialogPillOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final pillColor = isDestructive
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;
    final iconBgColor = isDestructive ? colorScheme.error : colorScheme.primary;
    final iconFgColor = isDestructive
        ? colorScheme.onError
        : colorScheme.onPrimary;
    final textColor = isDestructive
        ? colorScheme.onErrorContainer
        : colorScheme.onPrimaryContainer;

    return Material(
      color: pillColor,
      borderRadius: BorderRadius.circular(40),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconFgColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
