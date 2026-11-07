import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/progress_ring.dart';
import 'package:jdonut/features/auth/presentation/widgets/auth_background.dart';
import 'package:jdonut/features/auth/presentation/widgets/terms_text.dart';

/// Layout shared by Phone, OTP, Name and Date of birth:
/// back arrow + progress ring, title, form, bottom action + terms.
class AuthStepScaffold extends StatelessWidget {
  const AuthStepScaffold({
    required this.title,
    required this.progress,
    required this.previousProgress,
    required this.body,
    this.action,
    super.key,
  });

  final String title;
  final double progress;
  final double previousProgress;
  final Widget body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _topBar(context),
                Expanded(child: _content(context)),
                ?action,
                const SizedBox(height: AppSpacing.s4),
                const TermsText(),
                const SizedBox(height: AppSpacing.s4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) => SizedBox(
    height: AppSizes.buttonHeight,
    child: Row(
      children: [
        IconButton(
          tooltip: context.l10n.back,
          onPressed: () => context.canPop() ? context.pop() : null,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const Spacer(),
        ProgressRing(progress: progress, from: previousProgress),
      ],
    ),
  );

  Widget _content(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(top: AppSpacing.s4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: context.text.headlineLarge),
        const SizedBox(height: AppSpacing.s6),
        body,
      ],
    ),
  );
}
