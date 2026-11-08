import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jdonut/core/constants/app_assets.dart';
import 'package:jdonut/core/images/app_image_cache.dart';
import 'package:jdonut/core/motion/app_motion.dart';
import 'package:jdonut/core/motion/motion_context.dart';
import 'package:jdonut/core/network/api_paths.dart';
import 'package:jdonut/core/theme/theme.dart';

/// The one image widget. Order of preference:
/// 1. server image from the disk cache (works offline once downloaded),
/// 2. server image from the network, with the bundled asset as placeholder,
/// 3. the bundled asset (first launch offline, server down, 404),
/// 4. the app logo in grayscale.
class AppImage extends StatelessWidget {
  const AppImage({
    required this.assetPath,
    this.imageUrl,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    super.key,
  });

  final String? assetPath;

  /// Relative (`/static/...`) or absolute server URL.
  final String? imageUrl;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final url = ApiPaths.resolve(imageUrl);
    final local = _AssetOrFallback(
      assetPath: assetPath,
      fit: fit,
      semanticLabel: semanticLabel,
    );
    if (url == null) return local;
    return CachedNetworkImage(
      imageUrl: url,
      cacheManager: AppImageCache.instance,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      fadeInDuration: context.motion(AppDurations.medium),
      placeholder: (_, _) => local,
      errorWidget: (_, _, _) => local,
      imageBuilder: (_, provider) => Semantics(
        image: true,
        label: semanticLabel,
        child: Image(
          image: provider,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}

class _AssetOrFallback extends StatelessWidget {
  const _AssetOrFallback({
    required this.assetPath,
    required this.fit,
    this.semanticLabel,
  });

  final String? assetPath;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final path = assetPath;
    if (path == null) return const _LogoFallback();
    return Image.asset(
      path,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      semanticLabel: semanticLabel,
      errorBuilder: (_, _, _) => const _LogoFallback(),
    );
  }
}

/// Last resort when there is no cached, network or bundled image:
/// the app logo in grayscale on a neutral background.
class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  /// Luminance weights (Rec. 709) → a grayscale colour matrix.
  static const ColorFilter _grayscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);
  static const double _logoFraction = 0.6;
  static const double _logoOpacity = 0.45;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colors.outlineVariant,
    child: Center(
      child: FractionallySizedBox(
        widthFactor: _logoFraction,
        heightFactor: _logoFraction,
        child: Opacity(
          opacity: _logoOpacity,
          child: ColorFiltered(
            colorFilter: _grayscale,
            child: Image.asset(
              AppAssets.logoTransparent,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    ),
  );
}
