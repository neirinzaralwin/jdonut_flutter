import 'package:flutter/material.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';

/// Google / Apple / Facebook — no real integration (brief); a snackbar says so.
class SocialSignInRow extends StatelessWidget {
  const SocialSignInRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final providers = [
      (l10n.socialProviderGoogle, const Text('G')),
      (l10n.socialProviderApple, const Icon(Icons.apple)),
      (l10n.socialProviderFacebook, const Icon(Icons.facebook)),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final (name, icon) in providers)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s2),
            child: _SocialButton(name: name, icon: icon),
          ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.name, required this.icon});

  final String name;
  final Widget icon;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: name,
    child: Material(
      color: context.colors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(context.l10n.socialSignInUnavailable(name))),
          ),
        child: SizedBox.square(
          dimension: AppSizes.socialButton,
          child: Center(
            child: DefaultTextStyle(
              style: context.text.titleLarge!,
              child: IconTheme(
                data: IconThemeData(color: context.colors.onSurface),
                child: icon,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
