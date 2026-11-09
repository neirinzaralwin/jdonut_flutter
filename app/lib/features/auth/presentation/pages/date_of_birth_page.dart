import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jdonut/core/constants/app_constants.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/widgets/app_button.dart';
import 'package:jdonut/features/auth/domain/entities/auth_mode.dart';
import 'package:jdonut/features/auth/domain/validators/date_of_birth_validator.dart';
import 'package:jdonut/features/auth/presentation/auth_progress.dart';
import 'package:jdonut/features/auth/presentation/providers/auth_dependencies.dart';
import 'package:jdonut/features/auth/presentation/providers/register_notifier.dart';
import 'package:jdonut/features/auth/presentation/providers/registration_draft.dart';
import 'package:jdonut/features/auth/presentation/widgets/auth_step_scaffold.dart';
import 'package:jdonut/features/auth/presentation/widgets/birth_date_boxes.dart';
import 'package:jdonut/features/auth/presentation/widgets/birthday_picker.dart';

/// Screen 6: Month / Day / Year boxes like the design; tapping one opens the
/// native date picker (wheel on iOS, calendar on Android).
class DateOfBirthPage extends ConsumerStatefulWidget {
  const DateOfBirthPage({super.key});

  @override
  ConsumerState<DateOfBirthPage> createState() => _DateOfBirthPageState();
}

class _DateOfBirthPageState extends ConsumerState<DateOfBirthPage> {
  late DateTime _pickedDate;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(registrationDraftProvider);
    final today = ref.read(clockProvider)();
    _pickedDate = _draftDate(draft) ?? _defaultDate(today);
  }

  DateTime? _draftDate(RegistrationDraftState draft) {
    final month = draft.birthMonth;
    final day = int.tryParse(draft.birthDay);
    final year = int.tryParse(draft.birthYear);
    if (month == null || day == null || year == null) return null;
    try {
      final date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day) {
        return null;
      }
      return date;
    } on Exception {
      return null;
    }
  }

  DateTime _defaultDate(DateTime today) => DateTime(
    today.year - AppConstants.minimumAgeYears,
    today.month,
    today.day,
  );

  void _setDate(DateTime date) {
    setState(() => _pickedDate = date);
    ref
        .read(registrationDraftProvider.notifier)
        .updateBirthDate(
          month: date.month,
          day: date.day.toString(),
          year: date.year.toString(),
        );
  }

  /// A failed fake register call shows a snackbar.
  void _listenForFailure() {
    ref.listen(registerSubmitProvider.select((state) => state.failure), (
      _,
      failure,
    ) {
      if (failure == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.errorGeneric)));
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenForFailure();
    final draft = ref.watch(registrationDraftProvider);
    final error = validateDateOfBirth(
      year: draft.birthYear.isEmpty ? null : int.tryParse(draft.birthYear),
      month: draft.birthMonth,
      day: draft.birthDay.isEmpty ? null : int.tryParse(draft.birthDay),
      today: ref.read(clockProvider)(),
    );
    final isComplete =
        draft.birthMonth != null &&
        draft.birthDay.isNotEmpty &&
        draft.birthYear.length == 4;
    final submit = ref.watch(registerSubmitProvider);
    return AuthStepScaffold(
      title: context.l10n.dobTitle,
      progress: AuthProgress.of(
        AuthProgress.dateOfBirthStep,
        AuthMode.register,
      ),
      previousProgress: AuthProgress.before(
        AuthProgress.dateOfBirthStep,
        AuthMode.register,
      ),
      body: BirthDateBoxes(
        date: isComplete ? _pickedDate : null,
        onTap: _openPicker,
        errorText: isComplete ? _message(error) : null,
      ),
      action: AppButton(
        label: context.l10n.continueLabel,
        isLoading: submit.isSubmitting,
        onPressed: isComplete && error == null
            ? ref.read(registerSubmitProvider.notifier).submit
            : null,
      ),
    );
  }

  Future<void> _openPicker() async {
    final selected = await showBirthdayPicker(
      context,
      initial: _pickedDate,
      today: ref.read(clockProvider)(),
    );
    if (!mounted) return;
    // The boxes are display-only: don't leave one looking focused.
    FocusScope.of(context).unfocus();
    if (selected != null) _setDate(selected);
  }

  String? _message(DateOfBirthError? error) => switch (error) {
    null => null,
    DateOfBirthError.invalidDate => context.l10n.dobInvalidDate,
    DateOfBirthError.inFuture => context.l10n.dobInFuture,
    DateOfBirthError.tooYoung => context.l10n.dobTooYoung(
      AppConstants.minimumAgeYears,
    ),
  };
}
