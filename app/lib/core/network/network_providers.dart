import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:jdonut/core/network/api_client.dart';
import 'package:jdonut/core/network/network_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_providers.g.dart';

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) => ApiClient.create(
  onBackendReachability: ref
      .read(networkStatusMonitorProvider)
      .reportBackendReachable,
);

@Riverpod(keepAlive: true)
NetworkStatusMonitor networkStatusMonitor(Ref ref) =>
    NetworkStatusMonitor(Connectivity());

/// Device internet status (connection toast, background refresh).
@Riverpod(keepAlive: true)
Stream<NetworkStatus> networkStatus(Ref ref) =>
    ref.watch(networkStatusMonitorProvider).watch().distinct();
