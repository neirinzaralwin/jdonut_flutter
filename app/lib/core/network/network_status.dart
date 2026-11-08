import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:jdonut/core/network/network_constants.dart';

enum NetworkStatus { online, offline }

/// Looks up a host name; non-empty result = the internet answered.
typedef HostLookup = Future<List<InternetAddress>> Function(String host);

/// Device internet and backend status (drives the connection banner/sync).
/// Online requires internet reachability and no known backend connection
/// failure. A successful API response clears the backend failure.
class NetworkStatusMonitor {
  NetworkStatusMonitor(this._connectivity, {HostLookup? lookup})
    : _lookup = lookup ?? InternetAddress.lookup;

  final Connectivity _connectivity;
  final HostLookup _lookup;
  final _backendChanges = StreamController<bool>.broadcast();
  bool? _backendReachable;
  bool _internetReachable = false;

  /// Called by the API client after a response or a connection failure.
  void reportBackendReachable(bool reachable) {
    if (_backendReachable == reachable) return;
    _backendReachable = reachable;
    _backendChanges.add(reachable);
  }

  /// Emits the current status, then every change.
  Stream<NetworkStatus> watch() {
    late final StreamController<NetworkStatus> output;
    StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
    StreamSubscription<bool>? backendSubscription;
    output = StreamController<NetworkStatus>(
      onListen: () async {
        _internetReachable = await _checkInternet(
          await _connectivity.checkConnectivity(),
        );
        output.add(_currentStatus);
        connectivitySubscription = _connectivity.onConnectivityChanged.listen((
          results,
        ) async {
          _internetReachable = await _checkInternet(results);
          output.add(_currentStatus);
        });
        backendSubscription = _backendChanges.stream.listen((_) {
          output.add(_currentStatus);
        });
      },
      onCancel: () async {
        await connectivitySubscription?.cancel();
        await backendSubscription?.cancel();
      },
    );
    return output.stream.distinct();
  }

  NetworkStatus get _currentStatus =>
      _internetReachable && _backendReachable != false
      ? NetworkStatus.online
      : NetworkStatus.offline;

  Future<bool> _checkInternet(List<ConnectivityResult> results) async {
    final hasInterface = results.any(
      (result) => result != ConnectivityResult.none,
    );
    if (!hasInterface) return false;
    return _canReachInternet();
  }

  Future<bool> _canReachInternet() async {
    try {
      final addresses = await _lookup(
        NetworkConstants.reachabilityHost,
      ).timeout(NetworkConstants.reachabilityTimeout);
      return addresses.any((address) => address.rawAddress.isNotEmpty);
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }
}
