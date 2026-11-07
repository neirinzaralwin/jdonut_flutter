import 'package:flutter/painting.dart';

/// Raw palette sampled from the code-test screen designs.
/// Widgets must not use these directly — use `Theme.of(context).colorScheme`
/// or `context.appColors` (AppColorsExtension). See docs/knowledge-base/design_system.md.
abstract final class AppPalette {
  // Brand
  static const Color sky = Color(0xFF59CFEC); // primary CTA, active tab, Earn
  static const Color skyLight = Color(0xFFA4E4F4);
  static const Color skySubtle = Color(0xFFE0F5FB);
  static const Color pink = Color(0xFFF2599F); // links, progress ring, points
  static const Color pinkLight = Color(0xFFF893B8);
  static const Color pinkSubtle = Color(0xFFFCEDF2); // auth gradient top
  static const Color orange = Color(
    0xFFFE7E1E,
  ); // New / discount badges, Rewards pill
  static const Color orangeSubtle = Color(0xFFFDECDE); // Home header wash
  static const Color purple = Color(0xFF5D59A6); // promo banner

  // Neutrals
  static const Color ink = Color(0xFF1A1A1A); // headings, body
  static const Color inkSecondary = Color(0xFF8C8E93); // hints, captions
  static const Color inkDisabled = Color(0xFFB8B9C1);
  static const Color surface = Color(0xFFFFFFFF); // cards, inputs
  static const Color background = Color(0xFFF5F5F7); // Home / Product scaffold
  static const Color divider = Color(0xFFEEF0F1); // tab track, ring track

  // Tiers
  static const Color tierSilver = Color(0xFFC9D4D5);
  static const Color tierGold = Color(0xFFF9E3A0);
  static const Color tierPlatinum = Color(0xFFA4E4F4);

  // Illustration (DonutArt painter only)
  static const Color dough = Color(0xFFE2A469);
  static const Color doughShadow = Color(0xFFC07F45);
  static const Color chocolate = Color(0xFF6B3E26);
  static const Color sprinkleYellow = Color(0xFFFFD166);

  // Feedback
  static const Color success = Color(0xFF7DC37A);
  static const Color error = Color(0xFFE5484D);
}
