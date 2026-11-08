import 'package:flutter/material.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/features/rewards/domain/entities/challenge.dart';

/// "Eat more earn more" / "Gift": a sky pill slides behind the selected
/// tab; the other tab is a white outlined pill.
class ChallengeTabs extends StatelessWidget {
  const ChallengeTabs({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final ChallengeTab selected;
  final ValueChanged<ChallengeTab> onSelected;

  static const double _height = 44;
  static const double _border = 1.5;

  @override
  Widget build(BuildContext context) {
    final labels = {
      ChallengeTab.eatMore: context.l10n.tabEatMore,
      ChallengeTab.gift: context.l10n.tabGift,
    };
    final widths = _widths(context, labels);
    final selectedLeft = selected == ChallengeTab.eatMore
        ? 0.0
        : widths[ChallengeTab.eatMore]! + AppSpacing.s2;
    return SizedBox(
      height: _height,
      width: widths.values.reduce((a, b) => a + b) + AppSpacing.s2,
      child: Stack(
        children: [
          _row((tab) => _TabSlot(width: widths[tab]!)),
          AnimatedPositioned(
            duration: context.motion(AppDurations.tabSwitch),
            curve: AppCurves.emphasized,
            left: selectedLeft,
            top: 0,
            bottom: 0,
            width: widths[selected],
            child: _pill(context),
          ),
          _row(
            (tab) => _TabLabel(
              label: labels[tab]!,
              width: widths[tab]!,
              isSelected: tab == selected,
              onTap: () => onSelected(tab),
            ),
          ),
        ],
      ),
    );
  }

  /// The sky pill that slides behind the selected tab.
  Widget _pill(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.primary,
      borderRadius: BorderRadius.circular(AppRadii.pill),
    ),
  );

  /// One widget per tab, with the gap between them. Used twice: the outlined
  /// slots under the sliding pill, and the labels above it.
  Widget _row(Widget Function(ChallengeTab tab) build) => Row(
    children: [
      for (final (index, tab) in ChallengeTab.values.indexed) ...[
        if (index > 0) const SizedBox(width: AppSpacing.s2),
        build(tab),
      ],
    ],
  );

  /// Each tab is as wide as its label plus padding, so the pill can slide
  /// to an exact size.
  Map<ChallengeTab, double> _widths(
    BuildContext context,
    Map<ChallengeTab, String> labels,
  ) => {
    for (final entry in labels.entries)
      entry.key:
          _textWidth(context, entry.value, context.text.titleSmall) +
          AppSpacing.s5 * 2,
  };

  double _textWidth(BuildContext context, String text, TextStyle? style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    return painter.width;
  }
}

/// The white outlined pill behind an unselected tab.
class _TabSlot extends StatelessWidget {
  const _TabSlot({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      border: Border.all(
        color: context.colors.outlineVariant,
        width: ChallengeTabs._border,
      ),
    ),
  );
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.width,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final double width;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: isSelected,
    button: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: context.motion(AppDurations.tabSwitch),
            style: context.text.titleSmall!.copyWith(
              color: isSelected
                  ? context.colors.onPrimary
                  : context.colors.onSurface,
            ),
            child: Text(label, maxLines: 1),
          ),
        ),
      ),
    ),
  );
}
