import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';
import 'package:jdonut/core/router/app_routes.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:jdonut/core/widgets/app_image.dart';
import 'package:jdonut/features/home/domain/entities/home_banner.dart';

/// Peeking banner carousel that loops and auto-advances every
/// [AppDurations.bannerAutoPlay]. A swipe restarts the timer.
class BannerCarousel extends StatefulWidget {
  const BannerCarousel({required this.banners, super.key});

  final List<HomeBanner> banners;

  static const double viewportFraction = 0.74;
  static const double aspectRatio = 1.4;

  /// Height for a given screen width (also used by the skeleton).
  static double heightFor(double width) =>
      width * viewportFraction / aspectRatio;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  // Start far from 0 so the user can swipe backwards too.
  static const int _loopStartMultiplier = 1000;

  late final PageController _controller = PageController(
    viewportFraction: BannerCarousel.viewportFraction,
    initialPage: widget.banners.length * _loopStartMultiplier,
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    if (widget.banners.length < 2) return;
    _timer = Timer.periodic(AppDurations.bannerAutoPlay, (_) => _next());
  }

  void _next() {
    if (!_controller.hasClients) return;
    final page = (_controller.page ?? 0).round() + 1;
    if (context.reduceMotion) {
      _controller.jumpToPage(page);
    } else {
      _controller.animateToPage(
        page,
        duration: AppDurations.slow,
        curve: AppCurves.standard,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: BannerCarousel.heightFor(MediaQuery.sizeOf(context).width),
      child: NotificationListener<ScrollStartNotification>(
        // A user drag restarts the 3 s countdown.
        onNotification: (notification) {
          if (notification.dragDetails != null) _restartTimer();
          return false;
        },
        child: PageView.builder(
          controller: _controller,
          itemBuilder: (context, index) {
            final banner = widget.banners[index % widget.banners.length];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s2),
              child: GestureDetector(
                onTap: banner.productId == null
                    ? null
                    : () => context.push(
                        AppRoutes.productPath(banner.productId!),
                      ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.banner),
                  child: AppImage(
                    assetPath: banner.assetPath,
                    imageUrl: banner.imageUrl,
                    semanticLabel: banner.title,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
