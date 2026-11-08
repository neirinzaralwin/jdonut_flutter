import 'package:flutter/material.dart';
import 'package:jdonut/core/theme/theme.dart';

/// White pill with a number, used on the orange pills (notifications on
/// Home, "Rewards (3)" on Rewards).
class CountBadge extends StatelessWidget {
  const CountBadge({
    required this.count,
    this.size = defaultSize,
    this.style,
    super.key,
  });

  final int count;
  final double size;
  final TextStyle? style;

  static const double defaultSize = 24;

  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(minWidth: size),
    height: size,
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s1),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(AppRadii.pill),
    ),
    child: Text(
      '$count',
      style: (style ?? context.text.labelLarge)?.copyWith(
        color: context.colors.onSurface,
      ),
    ),
  );
}
