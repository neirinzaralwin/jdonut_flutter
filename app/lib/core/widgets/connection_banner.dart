import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jdonut/core/error/result.dart';
import 'package:jdonut/core/l10n/l10n.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';
import 'package:jdonut/core/network/api_paths.dart';
import 'package:jdonut/core/network/network_providers.dart';
import 'package:jdonut/core/network/network_status.dart';
import 'package:jdonut/core/theme/theme.dart';

enum _BannerState { hidden, offline, backOnline, connected }

/// Floating, toast-like pill under the status bar (brief: offline banner):
/// - launch with internet + server answers → green "Connected to server"
/// - offline → dark "You're offline · showing saved data", stays while offline
/// - back online → morphs to green "You're back online"
/// Green toasts float away after [AppDurations.connectionToastVisible].
/// Feels like a toast (shadow, blur, drop-in with a spring) but follows the
/// network state. Floats over every screen; never shifts the layout.
class ConnectionBanner extends ConsumerStatefulWidget {
  const ConnectionBanner({super.key});

  @override
  ConsumerState<ConnectionBanner> createState() => _ConnectionBannerState();
}

class _ConnectionBannerState extends ConsumerState<ConnectionBanner> {
  _BannerState _state = _BannerState.hidden;

  /// Kept while hiding, so the pill leaves with its last look.
  _BannerState _lastVisible = _BannerState.offline;

  /// Last known status was offline (decides whether "back online" shows).
  bool _wasOffline = false;

  /// The launch check runs once, on the first status.
  bool _isFirstStatus = true;
  Timer? _hideTimer;
  Timer? _probeTimer;

  @override
  void initState() {
    super.initState();
    ref.listenManual(networkStatusProvider, (previous, next) {
      final status = next.value;
      if (status != null) _onStatus(status);
    }, fireImmediately: true);
  }

  void _onStatus(NetworkStatus status) {
    final isOffline = status == NetworkStatus.offline;
    final isLaunch = _isFirstStatus;
    _isFirstStatus = false;
    _hideTimer?.cancel();
    if (isOffline) {
      _show(_BannerState.offline);
      _scheduleProbe();
    } else if (_wasOffline) {
      _probeTimer?.cancel();
      _probeTimer = null;
      _showBriefly(_BannerState.backOnline);
    } else if (isLaunch) {
      unawaited(_confirmServer());
    }
    _wasOffline = isOffline;
  }

  /// Launch with internet: say "Connected to server" only if it answers.
  Future<void> _confirmServer() async {
    final health = await ref
        .read(apiClientProvider)
        .get<Object>(ApiPaths.health, (data) => data);
    if (!mounted || health is! Ok || _wasOffline) return;
    _showBriefly(_BannerState.connected);
  }

  void _scheduleProbe() {
    _probeTimer?.cancel();
    _probeTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted || !_wasOffline) return;
      unawaited(_probeServer());
    });
  }

  Future<void> _probeServer() async {
    final health = await ref
        .read(apiClientProvider)
        .get<Object>(ApiPaths.health, (data) => data);
    if (!mounted || health is Ok || !_wasOffline) return;
    _scheduleProbe();
  }

  void _showBriefly(_BannerState state) {
    _hideTimer?.cancel();
    _show(state);
    _hideTimer = Timer(AppDurations.connectionToastVisible, () {
      if (mounted) setState(() => _state = _BannerState.hidden);
    });
  }

  void _show(_BannerState state) => setState(() {
    _state = state;
    _lastVisible = state;
  });

  @override
  void dispose() {
    _hideTimer?.cancel();
    _probeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _state != _BannerState.hidden;
    final duration = context.motion(AppDurations.bannerSlide);
    final curve = visible ? AppCurves.spring : AppCurves.exit;
    return IgnorePointer(
      child: SafeArea(
        child: Padding(
          // Keeps the pill inside the screen on narrow phones / long text.
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.s2,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: AnimatedSlide(
              offset: visible
                  ? Offset.zero
                  : const Offset(0, -AppMotionValues.bannerHiddenOffset),
              duration: duration,
              curve: curve,
              child: AnimatedScale(
                scale: visible ? 1 : AppMotionValues.toastHiddenScale,
                duration: duration,
                curve: curve,
                child: AnimatedOpacity(
                  opacity: visible ? 1 : 0,
                  duration: duration,
                  curve: AppCurves.standard,
                  child: Semantics(
                    liveRegion: true,
                    child: _Pill(state: visible ? _state : _lastVisible),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.state});

  final _BannerState state;

  static const double _shadowAlpha = 0.3;
  static const double _fillAlpha = 0.88;
  static const double _blurSigma = 12;

  @override
  Widget build(BuildContext context) {
    final isGreen = state != _BannerState.offline;
    final morph = context.motion(AppDurations.medium);
    final color = isGreen
        ? context.appColors.success
        : context.colors.onSurface;
    // Coloured shadow outside the clip; blur + translucent fill inside it.
    return AnimatedContainer(
      duration: morph,
      curve: AppCurves.standard,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: _shadowAlpha),
            blurRadius: AppSpacing.s5,
            offset: const Offset(0, AppSpacing.s2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
          child: AnimatedContainer(
            duration: morph,
            curve: AppCurves.standard,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s4,
              vertical: AppSpacing.s3,
            ),
            color: color.withValues(alpha: _fillAlpha),
            child: _Content(state: state, morph: morph),
          ),
        ),
      ),
    );
  }
}

/// Icon + text; cross-fades and resizes when the message changes.
class _Content extends StatelessWidget {
  const _Content({required this.state, required this.morph});

  final _BannerState state;
  final Duration morph;

  @override
  Widget build(BuildContext context) {
    final foreground = context.colors.surface;
    return AnimatedSize(
      duration: morph,
      curve: AppCurves.standard,
      child: AnimatedSwitcher(
        duration: morph,
        switchInCurve: AppCurves.standard,
        switchOutCurve: AppCurves.exit,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: AppMotionValues.toastHiddenScale,
              end: 1,
            ).animate(animation),
            child: child,
          ),
        ),
        child: Row(
          key: ValueKey(state),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              switch (state) {
                _BannerState.connected => Icons.cloud_done_rounded,
                _BannerState.backOnline => Icons.wifi_rounded,
                _BannerState.offline ||
                _BannerState.hidden => Icons.cloud_off_rounded,
              },
              size: AppSpacing.s4,
              color: foreground,
            ),
            const SizedBox(width: AppSpacing.s2),
            Flexible(
              child: Text(
                switch (state) {
                  _BannerState.connected => context.l10n.connectedToServer,
                  _BannerState.backOnline => context.l10n.backOnline,
                  _BannerState.offline ||
                  _BannerState.hidden => context.l10n.offlineBanner,
                },
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.text.labelSmall?.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
