import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        l10n.noTransaction,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
