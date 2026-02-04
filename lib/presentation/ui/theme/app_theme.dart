import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tema do aplicativo RichLudo
class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: LightPiColors.primary,
        onPrimary: LightPiColors.onPrimary,
        primaryContainer: LightPiColors.primaryContainer,
        onPrimaryContainer: LightPiColors.onPrimaryContainer,
        secondary: LightPiColors.secondary,
        onSecondary: LightPiColors.onSecondary,
        secondaryContainer: LightPiColors.secondaryContainer,
        onSecondaryContainer: LightPiColors.onSecondaryContainer,
        tertiary: LightPiColors.tertiary,
        onTertiary: LightPiColors.onTertiary,
        tertiaryContainer: LightPiColors.tertiaryContainer,
        onTertiaryContainer: LightPiColors.onTertiaryContainer,
        surface: LightPiColors.surface,
        onSurface: LightPiColors.onSurface,
        surfaceContainerHighest: LightPiColors.surfaceVariant,
        onSurfaceVariant: LightPiColors.onSurfaceVariant,
        outline: LightPiColors.outline,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: DarkPiColors.primary,
        onPrimary: DarkPiColors.onPrimary,
        primaryContainer: DarkPiColors.primaryContainer,
        onPrimaryContainer: DarkPiColors.onPrimaryContainer,
        secondary: DarkPiColors.secondary,
        onSecondary: DarkPiColors.onSecondary,
        secondaryContainer: DarkPiColors.secondaryContainer,
        onSecondaryContainer: DarkPiColors.onSecondaryContainer,
        tertiary: DarkPiColors.tertiary,
        onTertiary: DarkPiColors.onTertiary,
        tertiaryContainer: DarkPiColors.tertiaryContainer,
        onTertiaryContainer: DarkPiColors.onTertiaryContainer,
        surface: DarkPiColors.surface,
        onSurface: DarkPiColors.onSurface,
        surfaceContainerHighest: DarkPiColors.surfaceVariant,
        onSurfaceVariant: DarkPiColors.onSurfaceVariant,
        outline: DarkPiColors.outline,
      ),
    );
  }

  /// Retorna a cor de fundo para receita baseada no tema
  static Color incomeBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkPiColors.incomeBackground
        : LightPiColors.incomeBackground;
  }

  /// Retorna a cor de fundo para despesa baseada no tema
  static Color expenseBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkPiColors.expenseBackground
        : LightPiColors.expenseBackground;
  }

  /// Retorna a cor de dinheiro baseada no tema
  static Color moneyColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkPiColors.money
        : LightPiColors.money;
  }

  /// Retorna a cor dourada
  static Color goldenColor() => PiColors.golden;

  /// Retorna a cor de fundo do dock
  static Color dockBackground() => PiColors.dockBackground;
}
