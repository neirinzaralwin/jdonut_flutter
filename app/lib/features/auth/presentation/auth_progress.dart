import 'package:jdonut/features/auth/domain/entities/auth_mode.dart';

/// Ring progress per step: register has 4 steps, log in has 2 (phone, OTP).
abstract final class AuthProgress {
  static const int phoneStep = 1;
  static const int otpStep = 2;
  static const int nameStep = 3;
  static const int dateOfBirthStep = 4;

  static const int _registerSteps = 4;
  static const int _logInSteps = 2;

  static double of(int step, AuthMode mode) =>
      step / (mode == AuthMode.register ? _registerSteps : _logInSteps);

  static double before(int step, AuthMode mode) => of(step - 1, mode);
}
