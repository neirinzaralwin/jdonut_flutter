# 04 — Task 3: Rewards screen — motion and presentation

Rewards tab (screen 10). No button needs logic: Rewards, Earn and Gift tab need visual feedback only. **Read points and challenges from the same local data as Home.**

## Minimum animations
- **Points ring:** sweeps 0 → member progress while total counts up to 680,000.
- **Tier ladder:** Silver, Gold, Platinum appear in order; current tier highlighted; line to next tier fills to show progress.
- **Tabs:** "Eat more earn more" / "Gift" switch with moving indicator; card list changes with a transition.
- **Challenge cards:** enter staggered. Progress in own artwork: donut colours in by quarters (1/4, 4/4); coffee arc fills to 9/12.
- **Earn button:** active with attention cue when challenge complete (4/4), grey otherwise; press feedback, no action.
- **Rewards badge (3):** pops in on entry.
- **Bottom nav:** active pill slides between Home and Reward.

Draw ring and progress art with **CustomPainter** (or Rive). Donut/coffee photos can be image assets.
