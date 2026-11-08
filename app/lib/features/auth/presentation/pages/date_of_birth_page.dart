import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jdonut/core/constants/app_constants.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/app_button.dart';
import 'package:jdonut/core/widgets/app_text_field.dart';
import 'package:jdonut/features/auth/domain/entities/auth_mode.dart';
import 'package:jdonut/features/auth/domain/validators/date_of_birth_validator.dart';
import 'package:jdonut/features/auth/presentation/auth_progress.dart';
import 'package:jdonut/features/auth/presentation/providers/auth_dependencies.dart';
import 'package:jdonut/features/auth/presentation/providers/register_notifier.dart';
import 'package:jdonut/features/auth/presentation/providers/registration_draft.dart';
import 'package:jdonut/features/auth/presentation/widgets/auth_step_scaffold.dart';

class DateOfBirthPage extends ConsumerStatefulWidget {
  const DateOfBirthPage({super.key});

  @override
  ConsumerState<DateOfBirthPage> createState() => _DateOfBirthPageState();
}

class _DateOfBirthPageState extends ConsumerState<DateOfBirthPage> {
  late DateTime _pickedDate;
  final TextEditingController _birthdayController = TextEditingController();

  @override
  void dispose() {
    _birthdayController.dispose();
    super.dispose();
  }

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
    final birthdayText = isComplete
        ? DateFormat.yMMMMd(
            Localizations.localeOf(context).toString(),
          ).format(_pickedDate)
        : '';
    if (_birthdayController.text != birthdayText) {
      _birthdayController.text = birthdayText;
    }
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            key: const ValueKey('birthday-picker-field'),
            controller: _birthdayController,
            hintText: context.l10n.selectBirthday,
            readOnly: true,
            onTap: _openPicker,
            suffixIcon: Icon(
              Icons.calendar_month_outlined,
              color: context.colors.onSurfaceVariant,
            ),
            errorText: isComplete ? _message(error) : null,
          ),
        ],
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
    if (Platform.isIOS) {
      await _showCupertinoPicker();
    } else {
      await _showMaterialPicker();
    }
  }

  Future<void> _showMaterialPicker() async {
    final today = ref.read(clockProvider)();
    final selected = await showDatePicker(
      context: context,
      initialDate: _pickedDate.isAfter(today) ? today : _pickedDate,
      firstDate: DateTime(1900),
      lastDate: today,
      helpText: context.l10n.selectBirthday,
    );
    if (selected != null) _setDate(selected);
  }

  Future<void> _showCupertinoPicker() async {
    final today = ref.read(clockProvider)();
    var selected = _pickedDate.isAfter(today) ? today : _pickedDate;
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.sheet),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SizedBox(
          height: 390,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s5,
                  AppSpacing.s4,
                  AppSpacing.s3,
                  AppSpacing.s2,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.selectBirthday,
                        style: context.text.titleLarge?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: selected,
                  maximumDate: today,
                  minimumDate: DateTime(1900),
                  onDateTimeChanged: (date) => selected = date,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s5,
                  AppSpacing.s2,
                  AppSpacing.s5,
                  AppSpacing.s4,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(selected),
                    child: Text(context.l10n.select),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (result != null) _setDate(result);
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
