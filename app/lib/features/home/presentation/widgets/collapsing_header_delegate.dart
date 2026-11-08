import 'package:flutter/widgets.dart';

/// Header that the content below scrolls *over*: the sliver shrinks at full
/// scroll speed while its child moves up only by [parallax] of that, so the
/// sections slide up and cover the carousel from the bottom.
class CollapsingHeaderDelegate extends SliverPersistentHeaderDelegate {
  const CollapsingHeaderDelegate({
    required this.expandedHeight,
    required this.child,
    this.parallax = defaultParallax,
  });

  static const double defaultParallax = 0.35;

  final double expandedHeight;
  final double parallax;
  final Widget child;

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => 0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.topCenter,
        minHeight: 0,
        maxHeight: double.infinity,
        child: Transform.translate(
          offset: Offset(0, -shrinkOffset * parallax),
          child: child,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(CollapsingHeaderDelegate oldDelegate) =>
      oldDelegate.expandedHeight != expandedHeight ||
      oldDelegate.parallax != parallax ||
      oldDelegate.child != child;
}
