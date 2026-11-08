import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/router/app_routes.dart';
import 'package:jdonut/core/widgets/app_button.dart';
import 'package:jdonut/core/widgets/app_text_field.dart';
import 'package:jdonut/features/auth/domain/validators/phone_validator.dart';
import 'package:jdonut/features/auth/presentation/auth_progress.dart';
import 'package:jdonut/features/auth/presentation/providers/phone_submit_notifier.dart';
import 'package:jdonut/features/auth/presentation/providers/registration_draft.dart';
import 'package:jdonut/features/auth/presentation/widgets/auth_step_scaffold.dart';
import 'package:jdonut/features/auth/presentation/widgets/phone_failure_message.dart';
import 'package:jdonut/features/auth/presentation/widgets/touched_focus_node.dart';

class PhonePage extends ConsumerStatefulWidget {
  const PhonePage({super.key});

  @override
  ConsumerState<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends ConsumerState<PhonePage> {
  static const int _maxInputLength = 15;

  late final TextEditingController _controller = TextEditingController(
    text: ref.read(registrationDraftProvider).phoneInput,
  );
  // Inline message only after the field loses focus (brief).
  late final TouchedFocusNode _focusNode = TouchedFocusNode(
    onTouched: () => setState(() {}),
  );

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final canContinue = await ref.read(phoneSubmitProvider.notifier).submit();
    if (!canContinue || !mounted) return;
    await context.push(AppRoutes.otp);
    if (mounted) ref.read(phoneSubmitProvider.notifier).reset();
  }

  void _onChanged(String value) {
    ref.read(registrationDraftProvider.notifier).updatePhoneInput(value);
    ref.read(phoneSubmitProvider.notifier).clearFailure();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(
      registrationDraftProvider.select((draft) => draft.mode),
    );
    final submit = ref.watch(phoneSubmitProvider);
    final isValid = validatePhone(_controller.text) == null;
    return AuthStepScaffold(
      title: context.l10n.phoneTitle,
      progress: AuthProgress.of(AuthProgress.phoneStep, mode),
      previousProgress: 0,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _phoneField(isValid: isValid),
          if (submit.failure != null)
            PhoneFailureMessage(failure: submit.failure!),
        ],
      ),
      action: AppButton(
        label: context.l10n.continueLabel,
        isLoading: submit.isSubmitting,
        onPressed: isValid ? _submit : null,
      ),
    );
  }

  Widget _phoneField({required bool isValid}) => AppTextField(
    controller: _controller,
    focusNode: _focusNode,
    hintText: context.l10n.phoneHint,
    prefixText: '$myanmarCountryCode  ',
    keyboardType: TextInputType.phone,
    textInputAction: TextInputAction.done,
    autofillHints: const [AutofillHints.telephoneNumberNational],
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[\d\s-]')),
      LengthLimitingTextInputFormatter(_maxInputLength),
    ],
    errorText: _focusNode.wasTouched && !isValid
        ? context.l10n.phoneErrorInvalid
        : null,
    onChanged: _onChanged,
    onSubmitted: (_) => isValid ? _submit() : null,
  );
}
