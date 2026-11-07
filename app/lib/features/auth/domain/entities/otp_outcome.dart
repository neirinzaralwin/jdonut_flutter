import 'package:jdonut/features/auth/domain/entities/user.dart';

/// Result of a correct OTP: returning users are signed in,
/// new users continue to the Name step.
sealed class OtpOutcome {
  const OtpOutcome();
}

final class SignedIn extends OtpOutcome {
  const SignedIn(this.user);
  final User user;
}

final class ContinueRegistration extends OtpOutcome {
  const ContinueRegistration();
}
