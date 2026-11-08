import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';
import 'package:jdonut/core/theme/theme.dart';

typedef NavItem = ({IconData icon, String label});

/// Floating sky bar on a pink strip. The pink active pill (icon + label)
/// slides to the selected tab while the slots resize.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onSelected,
    super.key,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  static const double _barHeight = 64;
  static const double _barRadius = 28;
  static const double _pillBorder = 2;

  /// The active slot is this many times wider than the others.
  static const double _activeWidthFactor = 2.3;

  /// Space scrolling content must leave so nothing hides behind the bar.
  static double overlapHeight(BuildContext context) =>
      _barHeight + _bottomPadding(context) + AppSpacing.s4;

  /// Only part of the home-indicator inset, so the bar sits lower.
  static double _bottomPadding(BuildContext context) => math.max(
    MediaQuery.paddingOf(context).bottom - _insetReduction,
    AppSpacing.s2,
  );

  static const double _insetReduction = AppSpacing.s5;

  @override
  Widget build(BuildContext context) {
    final bottomInset = _bottomPadding(context);
    return SizedBox(
      height: _barHeight + bottomInset,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _barHeight / 2 + bottomInset,
            child: ColoredBox(color: context.colors.secondary),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
            child: Container(
              padding: EdgeInsets.only(bottom: bottomInset),
              decoration: BoxDecoration(
                color: context.appColors.navBar,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(_barRadius),
                ),
              ),
              child: SizedBox(
                height: _barHeight,
                child: LayoutBuilder(builder: _slots),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slots(BuildContext context, BoxConstraints constraints) {
    final barWidth = constraints.maxWidth - AppSpacing.s4 * 2;
    final slotWidth = barWidth / (items.length - 1 + _activeWidthFactor);
    final activeWidth = slotWidth * _activeWidthFactor;
    final duration = context.motion(AppDurations.medium);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: duration,
            curve: AppCurves.standard,
            left: currentIndex * slotWidth,
            top: AppSpacing.s3,
            bottom: AppSpacing.s3,
            width: activeWidth,
            child: _pill(context),
          ),
          Positioned.fill(
            child: Row(
              children: [
                for (final (index, item) in items.indexed)
                  AnimatedContainer(
                    duration: duration,
                    curve: AppCurves.standard,
                    width: index == currentIndex ? activeWidth : slotWidth,
                    child: _NavButton(
                      item: item,
                      isActive: index == currentIndex,
                      onTap: () => onSelected(index),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.secondary,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      border: Border.all(color: context.colors.surface, width: _pillBorder),
    ),
  );
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.onPrimary;
    return Semantics(
      selected: isActive,
      button: true,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: color),
            Flexible(
              child: AnimatedSize(
                duration: context.motion(AppDurations.medium),
                curve: AppCurves.standard,
                child: isActive
                    ? Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.s2),
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          softWrap: false,
                          style: context.text.labelLarge?.copyWith(
                            color: color,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
