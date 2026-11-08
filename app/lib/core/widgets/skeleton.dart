import 'package:flutter/material.dart';
import 'package:jdonut/core/theme/theme.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmering placeholder block (brief: skeletons, not spinners).
class Skeleton extends StatelessWidget {
  const Skeleton({
    this.width,
    this.height,
    this.radius = AppRadii.card,
    super.key,
  });

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: context.colors.outlineVariant,
    highlightColor: context.colors.surface,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
  );
}
