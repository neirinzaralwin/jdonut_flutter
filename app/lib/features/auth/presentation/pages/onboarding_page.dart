import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/router/app_routes.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/app_button.dart';
import 'package:jdonut/core/widgets/entrance_controller_mixin.dart';
import 'package:jdonut/core/widgets/staggered_entrance.dart';
import 'package:jdonut/features/auth/domain/entities/auth_mode.dart';
import 'package:jdonut/features/auth/presentation/providers/registration_draft.dart';
import 'package:jdonut/features/auth/presentation/widgets/auth_background.dart';
import 'package:jdonut/features/auth/presentation/widgets/onboarding_hero.dart';
import 'package:jdonut/features/auth/presentation/widgets/social_sign_in_row.dart';
import 'package:jdonut/features/auth/presentation/widgets/terms_text.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with SingleTickerProviderStateMixin, EntranceControllerMixin {
  static const int _heroFlex = 5;
  static const int _contentFlex = 4;

  void _start(AuthMode mode) {
    ref.read(registrationDraftProvider.notifier).start(mode);
    unawaited(context.push(AppRoutes.phone));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: _heroFlex,
                child: OnboardingHero(animation: entrance),
              ),
              Expanded(flex: _contentFlex, child: _content(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final items = <Widget>[
      Text(
        context.l10n.onboardingTitle,
        textAlign: TextAlign.center,
        style: context.text.displayLarge,
      ),
      AppButton(
        label: context.l10n.letsGetStarted,
        onPressed: () => _start(AuthMode.register),
      ),
      _LogInPrompt(onLogIn: () => _start(AuthMode.logIn)),
      const SocialSignInRow(),
      const TermsText(),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        children: [
          for (final (index, item) in items.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s4),
              child: StaggeredEntrance(
                animation: entrance,
                slot: AppStagger.onboardingContent,
                index: index,
                child: item,
              ),
            ),
        ],
      ),
    );
  }
}

class _LogInPrompt extends StatelessWidget {
  const _LogInPrompt({required this.onLogIn});

  final VoidCallback onLogIn;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(context.l10n.alreadyHaveAccount, style: context.text.bodyMedium),
      TextButton(
        onPressed: onLogIn,
        child: Text(
          context.l10n.logIn,
          style: context.text.bodyMedium
              ?.withWeight(FontWeight.w700)
              .copyWith(color: context.appColors.link),
        ),
      ),
    ],
  );
}
