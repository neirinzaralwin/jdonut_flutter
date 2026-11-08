import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonut/core/network/network_status.dart';
import 'package:mocktail/mocktail.dart';

class _MockConnectivity extends Mock implements Connectivity {}

void main() {
  late _MockConnectivity connectivity;
  var lookups = 0;

  setUp(() {
    connectivity = _MockConnectivity();
    lookups = 0;
    when(
      () => connectivity.onConnectivityChanged,
    ).thenAnswer((_) => const Stream.empty());
  });

  Future<NetworkStatus> firstStatus(
    List<ConnectivityResult> interfaces,
    HostLookup lookup,
  ) {
    when(
      () => connectivity.checkConnectivity(),
    ).thenAnswer((_) async => interfaces);
    return NetworkStatusMonitor(connectivity, lookup: lookup).watch().first;
  }

  Future<List<InternetAddress>> answers(String host) async {
    lookups++;
    return [InternetAddress('142.250.0.1')];
  }

  test('no network interface is offline, without a lookup', () async {
    final status = await firstStatus([ConnectivityResult.none], answers);

    expect(status, NetworkStatus.offline);
    expect(lookups, 0);
  });

  test('Wi-Fi that reaches the internet is online', () async {
    final status = await firstStatus([ConnectivityResult.wifi], answers);

    expect(status, NetworkStatus.online);
  });

  test('Wi-Fi without internet is offline', () async {
    final status = await firstStatus([
      ConnectivityResult.wifi,
    ], (_) async => throw const SocketException('no route'));

    expect(status, NetworkStatus.offline);
  });
}
