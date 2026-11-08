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
    required this.frostLight,
    required this.navBar,
    required this.banner,
    required this.ringTrack,
    required this.textSecondary,
    required this.tierBronze,
    required this.tierSilver,
    required this.tierGold,
    required this.tierPlatinum,
    required this.success,
  });

  static const AppColorsExtension light = AppColorsExtension(
    link: AppPalette.pink,
    badge: AppPalette.orange,
    authGradientTop: AppPalette.pinkSubtle,
    homeHeader: AppPalette.peachHeader,
    frostLight: AppPalette.pinkLight,
    navBar: AppPalette.navBar,
    banner: AppPalette.purple,
    ringTrack: AppPalette.divider,
    textSecondary: AppPalette.inkSecondary,
    tierBronze: TierColors(
      AppPalette.tierBronzeLight,
      AppPalette.tierBronzeDark,
    ),
    tierSilver: TierColors(
      AppPalette.tierSilverLight,
      AppPalette.tierSilverDark,
    ),
    tierGold: TierColors(AppPalette.tierGoldLight, AppPalette.tierGoldDark),
    tierPlatinum: TierColors(
      AppPalette.tierPlatinumLight,
      AppPalette.tierPlatinumDark,
    ),
    success: AppPalette.success,
  );

  final Color link;
  final Color badge;
  final Color authGradientTop;
  final Color homeHeader;

  /// Light end of the pink icing gradient (points ring).
  final Color frostLight;
  final Color navBar;
  final Color banner;
  final Color ringTrack;
  final Color textSecondary;
  final TierColors tierBronze;
  final TierColors tierSilver;
  final TierColors tierGold;
  final TierColors tierPlatinum;
  final Color success;

  @override
  AppColorsExtension copyWith() => this;

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) => this;
}

/// A tier's light → dark pair, matching its badge icon.
@immutable
class TierColors {
  const TierColors(this.light, this.dark);

  final Color light;
  final Color dark;

  /// Diagonal shine, like the shield icons.
  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [light, dark],
  );
}
