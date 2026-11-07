import 'package:flutter/material.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';
import 'package:jdonut/core/theme/theme.dart';

typedef NavItem = ({IconData icon, String label});

/// Bottom navigation with an active pill that slides between tabs.
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

  static const double _height = 64;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ColoredBox(
      color: colors.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _height,
          child: Stack(
            children: [
              _pill(context),
              Row(
                children: [
                  for (final (index, item) in items.indexed)
                    Expanded(child: _item(context, index, item)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(BuildContext context) {
    final step = items.length > 1 ? 2 / (items.length - 1) : 0.0;
    return AnimatedAlign(
      alignment: Alignment(-1 + currentIndex * step, 0),
      duration: context.motion(AppDurations.medium),
      curve: AppCurves.standard,
      child: FractionallySizedBox(
        widthFactor: 1 / items.length,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s1,
            vertical: AppSpacing.s2,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.primary,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int index, NavItem item) {
    final isActive = index == currentIndex;
    final color = isActive
        ? context.colors.onPrimary
        : context.colors.onSurfaceVariant;
    return Semantics(
      selected: isActive,
      button: true,
      label: item.label,
      child: InkResponse(
        onTap: () => onSelected(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: color),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
