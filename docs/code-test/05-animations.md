# 05 — Animations and transitions

Animate as much as possible from first screen to Rewards. Table = minimum; more earns credit.

| Where | Expected |
|---|---|
| Onboarding | Donut circles drift in; title and buttons enter staggered |
| Registration steps | Shared-axis or slide transition between steps; progress ring animates 25% → 50% → 75% → 100%, then morphs into a check |
| Inputs | Focus and error states animate; OTP boxes shake on wrong code |
| Buttons | Scale on press; Continue morphs into loading state |
| Welcome | Donut tiles slide in staggered, then title fades up |
| Home | Skeleton shimmer while loading; sections enter staggered; banner carousel auto-plays |
| Product tile → detail | Hero on product image; quantity number animates on change |
| Tab switch | Bottom-nav pill slides; Rewards entrance as in Task 3 |

## Rules
- 60 fps in profile mode, no jank on mid-range Android.
- Respect Reduce Motion (`MediaQuery.disableAnimations`) — shorten or skip.
- **Durations and curves as named constants in one motion file** → `app/lib/core/motion/app_motion.dart`.
- Lottie/Rive allowed, but most motion should use Flutter's own animation APIs.
