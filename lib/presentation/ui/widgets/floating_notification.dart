import 'package:flutter/material.dart';

enum NotificationType { success, error, info }

class FloatingNotification extends StatefulWidget {
  final String message;
  final NotificationType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const FloatingNotification({
    super.key,
    required this.message,
    required this.type,
    required this.onDismiss,
    this.duration = const Duration(seconds: 4),
  });

  @override
  State<FloatingNotification> createState() => _FloatingNotificationState();
}

class _FloatingNotificationState extends State<FloatingNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Auto dismiss após a duração
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  Color _getBackgroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (widget.type) {
      NotificationType.success => colorScheme.primaryContainer,
      NotificationType.error => colorScheme.errorContainer,
      NotificationType.info => colorScheme.secondaryContainer,
    };
  }

  Color _getTextColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (widget.type) {
      NotificationType.success => colorScheme.onPrimaryContainer,
      NotificationType.error => colorScheme.onErrorContainer,
      NotificationType.info => colorScheme.onSecondaryContainer,
    };
  }

  IconData _getIcon() {
    return switch (widget.type) {
      NotificationType.success => Icons.check_circle_outline,
      NotificationType.error => Icons.error_outline,
      NotificationType.info => Icons.info_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getBackgroundColor(context);
    final textColor = _getTextColor(context);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          elevation: 8,
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getIcon(), color: textColor, size: 24),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    widget.message,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: textColor),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _dismiss,
                  icon: Icon(Icons.close, color: textColor, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
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

/// Helper para mostrar notificações flutuantes em uma tela
/// Retorna uma função para remover a notificação
OverlayEntry showFloatingNotification({
  required BuildContext context,
  required String message,
  required NotificationType type,
  Duration duration = const Duration(seconds: 4),
}) {
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 100,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: FloatingNotification(
            message: message,
            type: type,
            duration: duration,
            onDismiss: () {
              overlayEntry.remove();
            },
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);
  return overlayEntry;
}
