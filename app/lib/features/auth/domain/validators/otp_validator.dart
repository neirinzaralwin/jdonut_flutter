import 'package:jdonut/core/constants/app_constants.dart';

final RegExp _otpDigits = RegExp('^\\d{${AppConstants.otpLength}}\$');

/// True when [code] is exactly 6 digits — ready to verify.
bool isCompleteOtp(String code) => _otpDigits.hasMatch(code);

/// Entry locks after this many wrong codes, until Resend.
bool isOtpLocked(int wrongAttempts) =>
    wrongAttempts >= AppConstants.maxOtpAttempts;

int otpAttemptsLeft(int wrongAttempts) =>
    (AppConstants.maxOtpAttempts - wrongAttempts).clamp(
      0,
      AppConstants.maxOtpAttempts,
    );
