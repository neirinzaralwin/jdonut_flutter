# 01 — Screens and flow

Registration has 4 steps tracked by a progress ring (top right): phone → OTP → name → date of birth.

| # | Screen | Shows | Task |
|---|---|---|---|
| 1 | Onboarding | "Round food for every mood", Let's get started, Log in, Google / Apple / Facebook | 1 |
| 2 | Phone number | +95 prefix, number field, ring at step 1 of 4 | 1 |
| 3 | Verify number | 6 OTP boxes, resend countdown from 5:00 | 1 |
| 4 | Name (empty) | First name, last name fields | 1 |
| 5 | Name (filled) | Same screen with input | 1 |
| 6 | Date of birth | Month, day, year; ring becomes a check | 1 |
| 7 | Welcome | Donut tiles, "Welcome to the world of J'donuts", Let's explore | 2 |
| 8 | Home | Member header, banners, Seasonal specials, Popular, Order again, nearby shops, bottom nav | 2 |
| 9 | Product detail | Coconut Donut, product code, price in MMK, quantity, Add to cart with total | 2 |
| 10 | Rewards | Tier ladder, points ring, Eat more earn more / Gift tabs, challenge cards | 3 |

## Entry paths
- **New user:** Onboarding → Phone → OTP → Name → Date of birth → Welcome → Home.
- **Returning user:** Onboarding → Phone → OTP → Home.

## Bottom nav
5 icons. Only **Home** and **Reward** must work; other three open a simple placeholder. Settings tab must contain a **Log out** row (Task 1).

## Design assets
Designs belong to a client: build from them, but **never commit or publish the screenshots**. Keep any local copies outside the repo or in a git-ignored folder (`design_refs/`).
