import 'package:flutter/material.dart';
import 'package:jdonut/core/theme/app_colors_extension.dart';

/// Short access to theme tokens in widgets:
/// `context.colors.primary`, `context.text.titleLarge`,
/// `context.appColors.badge`.
/// Spacing/radii/sizes stay static: `AppSpacing.s4`, `AppRadii.card`.
extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}
