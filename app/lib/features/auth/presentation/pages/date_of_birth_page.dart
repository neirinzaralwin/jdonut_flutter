import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:jdonut/features/auth/presentation/widgets/month_field.dart';

class DateOfBirthPage extends ConsumerStatefulWidget {
  const DateOfBirthPage({super.key});

  @override
  ConsumerState<DateOfBirthPage> createState() => _DateOfBirthPageState();
}

class _DateOfBirthPageState extends ConsumerState<DateOfBirthPage> {
  static const int _dayDigits = 2;
  static const int _yearDigits = 4;

  late final RegistrationDraftState _draft = ref.read(
    registrationDraftProvider,
  );
  late final TextEditingController _day = TextEditingController(
    text: _draft.birthDay,
  );
  late final TextEditingController _year = TextEditingController(
    text: _draft.birthYear,
  );

  @override
  void dispose() {
    _day.dispose();
    _year.dispose();
    super.dispose();
  }

  void _update({int? month}) {
    ref
        .read(registrationDraftProvider.notifier)
        .updateBirthDate(month: month, day: _day.text, year: _year.text);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(registerSubmitProvider.select((state) => state.failure), (
      _,
      failure,
    ) {
      if (failure == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.errorGeneric)));
    });
    final month = ref.watch(
      registrationDraftProvider.select((draft) => draft.birthMonth),
    );
    final error = _error(month);
    final isComplete =
        month != null &&
        _day.text.isNotEmpty &&
        _year.text.length == _yearDigits;
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
        children: [
          MonthField(
            month: month,
            onSelected: (value) => _update(month: value),
          ),
          const SizedBox(height: AppSpacing.s4),
          _numberField(_day, context.l10n.dayHint, _dayDigits),
          const SizedBox(height: AppSpacing.s4),
          _numberField(
            _year,
            context.l10n.yearHint,
            _yearDigits,
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

  Widget _numberField(
    TextEditingController controller,
    String hint,
    int digits, {
    String? errorText,
  }) => AppTextField(
    controller: controller,
    hintText: hint,
    keyboardType: TextInputType.number,
    textInputAction: TextInputAction.next,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(digits),
    ],
    errorText: errorText,
    onChanged: (_) => _update(),
  );

  DateOfBirthError? _error(int? month) => validateDateOfBirth(
    year: int.tryParse(_year.text),
    month: month,
    day: int.tryParse(_day.text),
    today: ref.read(clockProvider)(),
  );

  String? _message(DateOfBirthError? error) => switch (error) {
    null => null,
    DateOfBirthError.invalidDate => context.l10n.dobInvalidDate,
    DateOfBirthError.inFuture => context.l10n.dobInFuture,
    DateOfBirthError.tooYoung => context.l10n.dobTooYoung(
      AppConstants.minimumAgeYears,
    ),
  };
}
