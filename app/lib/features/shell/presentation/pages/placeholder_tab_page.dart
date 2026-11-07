import 'package:flutter/material.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';

/// Tabs outside the demo scope (brief: "a simple placeholder").
class PlaceholderTabPage extends StatelessWidget {
  const PlaceholderTabPage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title, style: context.text.titleLarge)),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hourglass_empty_rounded,
              size: AppSpacing.s12,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              context.l10n.placeholderTitle,
              style: context.text.titleMedium,
            ),
            const SizedBox(height: AppSpacing.s2),
            Text(
              context.l10n.placeholderBody,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium,
            ),
          ],
        ),
      ),
    ),
  );
}
