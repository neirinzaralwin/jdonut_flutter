import 'package:flutter/material.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';

/// "? What's this?" label, a divider, and the product description.
class WhatsThis extends StatelessWidget {
  const WhatsThis({required this.description, super.key});

  final String description;

  static const double _labelWidth = 72;

  /// The "?" fills this much of its green circle.
  static const double _glyphRatio = 0.7;
  static const double _iconSize = 20;
  static const double _dividerWidth = 1;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: _labelWidth, child: _label(context)),
        VerticalDivider(
          width: AppSpacing.s6,
          thickness: _dividerWidth,
          color: context.colors.outlineVariant,
        ),
        Expanded(
          child: Text(
            description,
            style: context.text.bodyMedium?.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _label(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: _iconSize,
        height: _iconSize,
        decoration: BoxDecoration(
          color: context.appColors.success,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.question_mark_rounded,
          size: _iconSize * _glyphRatio,
          color: context.colors.onPrimary,
        ),
      ),
      const SizedBox(height: AppSpacing.s1),
      Text(context.l10n.whatsThis, style: context.text.titleSmall),
    ],
  );
}
