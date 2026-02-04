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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.dockBackground(),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BottomBarItem(
              icon: Icons.bar_chart,
              onTap: onChartClick ?? () {},
            ),
            const SizedBox(width: 8),
            _BottomBarItem(
              imagePath: 'assets/icons/add-item.png',
              onTap: onAddButtonClick,
              size: 70,
            ),
            const SizedBox(width: 8),
            _BottomBarItem(
              icon: Icons.settings,
              onTap: onSettingsClick ?? () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final VoidCallback onTap;
  final double size;

  const _BottomBarItem({
    this.icon,
    this.imagePath,
    required this.onTap,
    this.size = 70,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: imagePath != null
            ? Image.asset(
                imagePath!,
                width: size,
                height: size,
              )
            : Icon(
                icon,
                size: size,
                color: Theme.of(context).colorScheme.onSurface,
              ),
      ),
    );
  }
}
