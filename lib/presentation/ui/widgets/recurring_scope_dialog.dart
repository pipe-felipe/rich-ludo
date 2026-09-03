import 'package:flutter/material.dart';
import '../../../domain/model/recurring_scope.dart';
import '../../../l10n/app_localizations.dart';

class RecurringScopeDialog extends StatelessWidget {
  final String title;
  final Set<RecurringScope> disabledScopes;

  const RecurringScopeDialog({
    super.key,
    required this.title,
    this.disabledScopes = const {},
  });

  static Future<RecurringScope?> show(
    BuildContext context, {
    required String title,
    Set<RecurringScope> disabledScopes = const {},
  }) {
    return showDialog<RecurringScope>(
      context: context,
      builder: (_) =>
          RecurringScopeDialog(title: title, disabledScopes: disabledScopes),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _DialogOption(
              icon: Icons.today,
              label: l10n.recurringDeleteThisMonth,
              onTap: () => Navigator.of(context).pop(RecurringScope.thisMonth),
              isEnabled: !disabledScopes.contains(RecurringScope.thisMonth),
            ),
            _DialogOption(
              icon: Icons.arrow_back,
              label: l10n.recurringDeleteBackwards,
              onTap: () => Navigator.of(
                context,
              ).pop(RecurringScope.thisAndPreviousMonths),
              isEnabled: !disabledScopes.contains(
                RecurringScope.thisAndPreviousMonths,
              ),
            ),
            _DialogOption(
              icon: Icons.arrow_forward,
              label: l10n.recurringDeleteForwards,
              onTap: () =>
                  Navigator.of(context).pop(RecurringScope.thisAndFutureMonths),
              isEnabled: !disabledScopes.contains(
                RecurringScope.thisAndFutureMonths,
              ),
            ),
            const Divider(height: 16),
            _DialogOption(
              icon: Icons.delete_forever,
              label: l10n.recurringDeleteAll,
              onTap: () => Navigator.of(context).pop(RecurringScope.allMonths),
              isDestructive: true,
              isEnabled: !disabledScopes.contains(RecurringScope.allMonths),
            ),
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

class _DialogOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isEnabled;

  const _DialogOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = isDestructive ? colorScheme.error : colorScheme.primary;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 22, color: accentColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDestructive ? colorScheme.error : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
