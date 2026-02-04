import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const ErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 16),
          Text(
            l10n.errorLoading,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(l10n.tryAgain),
          ),
        ],
      ),
    );
  }
}
