import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/features/auth/domain/entities/new_user.dart';
import 'package:jdonut/features/auth/domain/validators/date_of_birth_validator.dart';
import 'package:jdonut/features/auth/presentation/providers/auth_dependencies.dart';
import 'package:jdonut/features/auth/presentation/providers/registration_draft.dart';
import 'package:jdonut/features/auth/presentation/providers/session_notifier.dart';
import 'package:jdonut/features/auth/presentation/providers/submit_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'register_notifier.g.dart';

/// Final registration step. On success the session becomes a new user and
/// the router guard shows Welcome.
@riverpod
class RegisterSubmit extends _$RegisterSubmit {
  @override
  SubmitState build() => const SubmitState();

  Future<void> submit() async {
    if (state.isSubmitting) return;
    final draft = ref.read(registrationDraftProvider);
    final birthDate = calendarDate(
      year: int.tryParse(draft.birthYear),
      month: draft.birthMonth,
      day: int.tryParse(draft.birthDay),
    );
    if (birthDate == null) return;

    state = const SubmitState(isSubmitting: true);
    final result = await ref
        .read(registerUserProvider)
        .call(
          NewUser(
            phone: draft.phone,
            firstName: draft.firstName,
            lastName: draft.lastName,
            dateOfBirth: birthDate,
          ),
        );
    if (!ref.mounted) return;

    switch (result) {
      case Ok(:final value):
        ref.read(sessionProvider.notifier).signedIn(value, isNewUser: true);
      // Success keeps "submitting": the router leaves this page, and a second
      // tap must not try to register the same number again.
      case Err(:final failure):
        state = SubmitState(failure: failure);
    }
  }
}
