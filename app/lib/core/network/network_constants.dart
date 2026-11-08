/// Timeouts and retry limits for every request (no unbounded waits).
abstract final class NetworkConstants {
  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);

  /// Internet check: quick, because it decides the connection toast.
  static const Duration reachabilityTimeout = Duration(seconds: 3);
  static const String reachabilityHost = 'google.com';

  /// Server health probe: one quick try, so the offline state shows fast.
  static const Duration probeTimeout = Duration(seconds: 2);

  static const int maxRetries = 3;
  static const Duration retryBaseDelay = Duration(milliseconds: 400);
}
