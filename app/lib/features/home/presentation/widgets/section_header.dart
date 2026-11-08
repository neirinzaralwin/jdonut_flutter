import 'package:flutter/material.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/placeholder_sheet.dart';

/// Section title with the round white arrow button.
class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.screenHorizontal,
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleLarge,
          ),
        ),
        Material(
          color: context.colors.surface,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => showPlaceholderSheet(context, title: title),
            child: SizedBox.square(
              dimension: AppSizes.iconButton,
              child: Icon(
                Icons.chevron_right_rounded,
                semanticLabel: context.l10n.seeAll,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
