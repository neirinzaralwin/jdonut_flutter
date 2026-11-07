import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonut/core/constants/app_constants.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/router/app_routes.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/app_button.dart';
import 'package:jdonut/core/widgets/app_text_field.dart';
import 'package:jdonut/features/auth/domain/entities/auth_mode.dart';
import 'package:jdonut/features/auth/domain/validators/name_validator.dart';
import 'package:jdonut/features/auth/presentation/auth_progress.dart';
import 'package:jdonut/features/auth/presentation/providers/registration_draft.dart';
import 'package:jdonut/features/auth/presentation/widgets/auth_step_scaffold.dart';
import 'package:jdonut/features/auth/presentation/widgets/touched_focus_node.dart';

class NamePage extends ConsumerStatefulWidget {
  const NamePage({super.key});

  @override
  ConsumerState<NamePage> createState() => _NamePageState();
}

class _NamePageState extends ConsumerState<NamePage> {
  late final RegistrationDraftState _draft = ref.read(
    registrationDraftProvider,
  );
  late final TextEditingController _firstName = TextEditingController(
    text: _draft.firstName,
  );
  late final TextEditingController _lastName = TextEditingController(
    text: _draft.lastName,
  );
  late final TouchedFocusNode _firstNameFocus = TouchedFocusNode(
    onTouched: _refresh,
  );
  late final TouchedFocusNode _lastNameFocus = TouchedFocusNode(
    onTouched: _refresh,
  );

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    super.dispose();
  }

  void _onChanged(String _) {
    ref
        .read(registrationDraftProvider.notifier)
        .updateName(firstName: _firstName.text, lastName: _lastName.text);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final firstError = validateFirstName(_firstName.text);
    final lastError = validateLastName(_lastName.text);
    final canContinue = firstError == null && lastError == null;
    return AuthStepScaffold(
      title: context.l10n.nameTitle,
      progress: AuthProgress.of(AuthProgress.nameStep, AuthMode.register),
      previousProgress: AuthProgress.before(
        AuthProgress.nameStep,
        AuthMode.register,
      ),
      body: Column(
        children: [
          AppTextField(
            controller: _firstName,
            focusNode: _firstNameFocus,
            hintText: context.l10n.firstNameHint,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.givenName],
            errorText: _firstNameFocus.wasTouched ? _message(firstError) : null,
            onChanged: _onChanged,
          ),
          const SizedBox(height: AppSpacing.s4),
          AppTextField(
            controller: _lastName,
            focusNode: _lastNameFocus,
            hintText: context.l10n.lastNameHint,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.familyName],
            // Optional field: show the message as soon as it is typed.
            errorText: _message(lastError),
            onChanged: _onChanged,
          ),
        ],
      ),
      action: AppButton(
        label: context.l10n.continueLabel,
        onPressed: canContinue
            ? () => context.push(AppRoutes.dateOfBirth)
            : null,
      ),
    );
  }

  String? _message(NameError? error) => switch (error) {
    null => null,
    NameError.required => context.l10n.nameRequired,
    NameError.tooLong => context.l10n.nameTooLong(AppConstants.nameMaxLength),
    NameError.invalidCharacters => context.l10n.nameInvalidCharacters,
  };
}
