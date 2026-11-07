import 'package:flutter/material.dart';
import 'package:jdonut/core/theme/app_colors.dart';

/// Brand colours that don't fit ColorScheme slots.
/// Access via `context.appColors` (see theme_context.dart).
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.link,
    required this.badge,
    required this.authGradientTop,
    required this.homeHeader,
    required this.banner,
    required this.ringTrack,
    required this.textSecondary,
    required this.tierSilver,
    required this.tierGold,
    required this.tierPlatinum,
    required this.success,
  });

  static const AppColorsExtension light = AppColorsExtension(
    link: AppPalette.pink,
    badge: AppPalette.orange,
    authGradientTop: AppPalette.pinkSubtle,
    homeHeader: AppPalette.orangeSubtle,
    banner: AppPalette.purple,
    ringTrack: AppPalette.divider,
    textSecondary: AppPalette.inkSecondary,
    tierSilver: AppPalette.tierSilver,
    tierGold: AppPalette.tierGold,
    tierPlatinum: AppPalette.tierPlatinum,
    success: AppPalette.success,
  );

  final Color link;
  final Color badge;
  final Color authGradientTop;
  final Color homeHeader;
  final Color banner;
  final Color ringTrack;
  final Color textSecondary;
  final Color tierSilver;
  final Color tierGold;
  final Color tierPlatinum;
  final Color success;

  @override
  AppColorsExtension copyWith() => this;

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) => this;
}
