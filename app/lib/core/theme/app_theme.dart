import 'package:flutter/material.dart';
import 'package:jdonut/core/theme/app_colors.dart';
import 'package:jdonut/core/theme/app_colors_extension.dart';
import 'package:jdonut/core/theme/app_typography.dart';

/// Single theme (light only — designs have no dark mode).
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: _colorScheme,
    scaffoldBackgroundColor: AppPalette.background,
    fontFamily: AppTypography.bodyFamily,
    textTheme: _textTheme,
    extensions: const [AppColorsExtension.light],
  );

  static const ColorScheme _colorScheme = ColorScheme.light(
    primary: AppPalette.sky,
    primaryContainer: AppPalette.skySubtle,
    secondary: AppPalette.pink,
    onSecondary: AppPalette.surface,
    tertiary: AppPalette.orange,
    onSurface: AppPalette.ink,
    onSurfaceVariant: AppPalette.inkSecondary,
    outlineVariant: AppPalette.divider,
    error: AppPalette.error,
  );

  static final TextTheme _textTheme = TextTheme(
    displayLarge: AppTypography.displayL,
    headlineLarge: AppTypography.headlineL,
    headlineMedium: AppTypography.headlineM,
    titleLarge: AppTypography.titleL,
    titleMedium: AppTypography.titleM,
    titleSmall: AppTypography.titleS,
    bodyLarge: AppTypography.bodyL,
    bodyMedium: AppTypography.bodyM,
    bodySmall: AppTypography.bodyS,
    labelLarge: AppTypography.labelL,
    labelSmall: AppTypography.labelS,
  ).apply(bodyColor: AppPalette.ink, displayColor: AppPalette.ink);
}
