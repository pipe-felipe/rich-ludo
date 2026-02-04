import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MainBottomBar extends StatelessWidget {
  final VoidCallback onAddButtonClick;
  final VoidCallback? onChartClick;
  final VoidCallback? onSettingsClick;

  const MainBottomBar({
    super.key,
    required this.onAddButtonClick,
    this.onChartClick,
    this.onSettingsClick,
  });

  @override
  Widget build(BuildContext context) {
    final double docIconSize = 70;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.dockBackground(),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BottomBarItem(
            imagePath: 'assets/icons/backup-icon.png',
            onTap: onChartClick ?? () {},
            size: docIconSize,
          ),
          _BottomBarItem(
            imagePath: 'assets/icons/save-icon.png',
            onTap: onSettingsClick ?? () {},
            size: docIconSize,
          ),
          _BottomBarItem(
            imagePath: 'assets/icons/add-item.png',
            onTap: onAddButtonClick,
            size: docIconSize,
          ),
        ],
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;
  final double size;

  const _BottomBarItem({this.imagePath, required this.onTap, this.size = 70});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(imagePath!, width: size, height: size),
      ),
    );
  }
}
