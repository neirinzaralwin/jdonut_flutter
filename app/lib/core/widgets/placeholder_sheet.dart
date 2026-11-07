import 'package:flutter/material.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';

/// Stand-in for features outside the demo (social sign-in, legal pages).
Future<void> showPlaceholderSheet(BuildContext context, {String? title}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: context.colors.surface,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          0,
          AppSpacing.screenHorizontal,
          AppSpacing.s6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title ?? context.l10n.placeholderTitle,
              style: context.text.titleLarge,
            ),
            const SizedBox(height: AppSpacing.s2),
            Text(context.l10n.placeholderBody, style: context.text.bodyMedium),
          ],
        ),
      ),
    ),
  );
}
