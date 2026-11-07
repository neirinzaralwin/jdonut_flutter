import 'package:flutter/painting.dart';

/// Nunito = headings/titles, Nunito Sans = body. Both bundled variable fonts,
/// so weight is applied with FontVariation (fontWeight alone won't move
/// the axis).
/// Myanmar script falls back to the platform font.
abstract final class AppTypography {
  static const String headingFamily = 'Nunito';
  static const String bodyFamily = 'NunitoSans';
  static const List<String> fallback = [
    'Noto Sans Myanmar',
    'Myanmar Sangam MN',
  ];

  static TextStyle _heading(double size, FontWeight weight, double height) =>
      _style(headingFamily, size, weight, height);

  static TextStyle _body(double size, FontWeight weight, double height) =>
      _style(bodyFamily, size, weight, height);

  static TextStyle _style(
    String family,
    double size,
    FontWeight weight,
    double height,
  ) => TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: size,
    height: height,
    fontWeight: weight,
    fontVariations: [FontVariation.weight(weight.value.toDouble())],
  );

  // Headings — Nunito
  static final TextStyle displayL = _heading(
    32,
    FontWeight.w800,
    1.2,
  ); // "Round food for every mood"
  static final TextStyle headlineL = _heading(
    28,
    FontWeight.w800,
    1.2,
  ); // auth step titles
  static final TextStyle headlineM = _heading(
    24,
    FontWeight.w800,
    1.25,
  ); // Rewards title, product name
  static final TextStyle titleL = _heading(
    20,
    FontWeight.w700,
    1.3,
  ); // section headers
  static final TextStyle titleM = _heading(
    16,
    FontWeight.w700,
    1.3,
  ); // card titles, tier names
  static final TextStyle titleS = _heading(
    14,
    FontWeight.w700,
    1.3,
  ); // tile names

  // Body — Nunito Sans
  static final TextStyle bodyL = _body(16, FontWeight.w400, 1.5);
  static final TextStyle bodyM = _body(14, FontWeight.w400, 1.45);
  static final TextStyle bodyS = _body(12, FontWeight.w400, 1.4);
  static final TextStyle labelL = _body(
    14,
    FontWeight.w800,
    1.2,
  ); // CTA (uppercase)
  static final TextStyle labelS = _body(11, FontWeight.w700, 1.2); // badges
  static final TextStyle numeric = _heading(
    28,
    FontWeight.w800,
    1.1,
  ); // points, OTP digits
}

/// Variable fonts need the weight axis set too — use this instead of
/// `copyWith(fontWeight: …)`.
extension TextStyleWeight on TextStyle {
  TextStyle withWeight(FontWeight weight) => copyWith(
    fontWeight: weight,
    fontVariations: [FontVariation.weight(weight.value.toDouble())],
  );
}
