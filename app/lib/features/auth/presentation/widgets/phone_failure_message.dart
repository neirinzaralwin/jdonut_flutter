import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jdonut/core/error/failure.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/features/auth/domain/entities/auth_mode.dart';
import 'package:jdonut/features/auth/presentation/providers/phone_submit_notifier.dart';
import 'package:jdonut/features/auth/presentation/providers/registration_draft.dart';

/// Inline message under the phone field. "Not registered" offers a Register
/// link; "already registered" offers a Log in link. Both keep the number.
class PhoneFailureMessage extends ConsumerWidget {
  const PhoneFailureMessage({required this.failure, super.key});

  final Failure failure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final (message, switchTo, linkLabel) = switch (failure) {
      AuthFailure(kind: AuthFailureKind.notRegistered) => (
        l10n.phoneNotRegistered,
        AuthMode.register,
        l10n.register,
      ),
      AuthFailure(kind: AuthFailureKind.alreadyRegistered) => (
        l10n.phoneAlreadyRegistered,
        AuthMode.logIn,
        l10n.logIn,
      ),
      _ => (l10n.errorGeneric, null, null),
    };
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s2),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            message,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.error,
            ),
          ),
          if (switchTo != null && linkLabel != null)
            TextButton(
              onPressed: () {
                ref
                    .read(registrationDraftProvider.notifier)
                    .switchMode(switchTo);
                ref.read(phoneSubmitProvider.notifier).clearFailure();
              },
              child: Text(
                linkLabel,
                style: context.text.bodySmall
                    ?.withWeight(FontWeight.w700)
                    .copyWith(color: context.appColors.link),
              ),
            ),
        ],
      ),
    );
  }
}
