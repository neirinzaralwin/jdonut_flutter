import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/placeholder_sheet.dart';

/// "By continuing… Terms of Use and Privacy Policy" with tappable links
/// that open a placeholder sheet.
class TermsText extends StatefulWidget {
  const TermsText({super.key});

  @override
  State<TermsText> createState() => _TermsTextState();
}

class _TermsTextState extends State<TermsText> {
  late final TapGestureRecognizer _termsTap = TapGestureRecognizer()
    ..onTap = () =>
        showPlaceholderSheet(context, title: context.l10n.termsOfUse);
  late final TapGestureRecognizer _privacyTap = TapGestureRecognizer()
    ..onTap = () =>
        showPlaceholderSheet(context, title: context.l10n.privacyPolicy);

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final base = context.text.bodySmall?.copyWith(
      color: context.appColors.textSecondary,
    );
    final link = base?.copyWith(color: context.appColors.link);
    return Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        style: base,
        children: [
          TextSpan(text: l10n.termsLead),
          TextSpan(text: l10n.termsOfUse, style: link, recognizer: _termsTap),
          TextSpan(text: l10n.termsAnd),
          TextSpan(
            text: l10n.privacyPolicy,
            style: link,
            recognizer: _privacyTap,
          ),
          TextSpan(text: l10n.termsTrail),
        ],
      ),
    );
  }
}
