# Motion Rules (Task 3 + flow — 20% of score)

Spec: `../code-test/04-task3-rewards.md`, `../code-test/05-animations.md`.

- **All** durations/curves/stagger steps in `core/motion/app_motion.dart`. No `Duration(...)` or `Curves.*` literals in features.
- Reduce Motion: read `MediaQuery.disableAnimationsOf(context)` through one helper (`context.motion.duration(AppDurations.medium)` → `Duration.zero` when disabled). Count-ups jump to final value; staggers show all at once.
- Prefer implicit animations (`AnimatedFoo`, `TweenAnimationBuilder`) for simple state changes; explicit `AnimationController` only for orchestration (ring + count-up, staggered lists, shake).
- One controller drives a whole stagger (`Interval`s), not N controllers.
- Painters (`CustomPainter`): `shouldRepaint` compares fields; wrap in `RepaintBoundary`; pass `Animation` as `repaint:` instead of rebuilding.
- Never animate layout-heavy properties per frame when `Transform`/`Opacity`/`FadeTransition` will do. Use `AnimatedBuilder` with `child:` to avoid rebuilding subtrees.
- Hero tags: `'product-image-${product.id}'` from one helper — tiles in multiple sections must not collide (prefix with section id).
- Route transitions defined once in `core/router/transitions.dart` (shared-axis for registration steps, fade-through for tabs).
- Dispose every controller. `vsync: this` via `SingleTickerProviderStateMixin`/`TickerProviderStateMixin`.
- Verify in **profile mode** on Android (`flutter run --profile`) with the performance overlay; target 60 fps, no raster jank.
