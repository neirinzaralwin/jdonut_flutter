import 'package:flutter/material.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/count_badge.dart';
import 'package:jdonut/core/widgets/placeholder_sheet.dart';

/// Orange bell pill attached to the right edge; stays pinned while
/// the page scrolls.
class NotificationPill extends StatelessWidget {
  const NotificationPill({required this.count, super.key});

  final int count;

  static const double _countSize = 22;
  static const BorderRadius _shape = BorderRadius.horizontal(
    left: Radius.circular(AppRadii.pill),
  );
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(
    AppSpacing.s4,
    AppSpacing.s2,
    AppSpacing.s3,
    AppSpacing.s2,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: '${context.l10n.notifications}: $count',
      child: Material(
        color: context.appColors.badge,
        borderRadius: _shape,
        child: InkWell(
          onTap: () =>
              showPlaceholderSheet(context, title: context.l10n.notifications),
          borderRadius: _shape,
          child: Padding(
            padding: _padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_none_rounded, color: colors.onPrimary),
                const SizedBox(width: AppSpacing.s1),
                CountBadge(
                  count: count,
                  size: _countSize,
                  style: context.text.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
