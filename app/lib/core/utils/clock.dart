/// Injectable "now" so date logic (age, OTP expiry) is testable.
typedef Clock = DateTime Function();

DateTime systemClock() => DateTime.now();
