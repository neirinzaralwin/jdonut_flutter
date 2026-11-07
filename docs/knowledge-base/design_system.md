# Design System — J'Donuts

Source: colours sampled from the screen designs in the code-test PDF (screens 1–10). Code: `app/lib/core/theme/`.
Brief rule: colours, type and spacing are tokens in one theme — **no hard-coded colours in widgets**.

## How widgets read tokens (mix approach)
Separate token files (like vint_flutter) **registered in one `ThemeData`** (brief: tokens in one theme), read through short `BuildContext` getters.

```dart
import 'package:jdonut/core/theme/theme.dart'; // one import

Text(l10n.popular, style: context.text.titleLarge);
ColoredBox(color: context.colors.primary);
BoxDecoration(color: context.appColors.badge, borderRadius: BorderRadius.circular(AppRadii.pill));
Padding(padding: const EdgeInsets.all(AppSpacing.s4));
context.text.bodyM?.copyWith(color: context.appColors.textSecondary);
```

| Need | Use | Never |
|---|---|---|
| Material colours | `context.colors.primary / secondary / tertiary / surface / onSurface / onSurfaceVariant / outlineVariant / error` | `Color(0x…)`, `Colors.*`, `AppPalette.*` in a widget |
| Brand colours outside ColorScheme | `context.appColors.link / badge / banner / authGradientTop / homeHeader / ringTrack / textSecondary / tier* / success` | — |
| Text | `context.text.displayLarge … labelSmall` + `.copyWith(...)` | `TextStyle(fontSize: …)` from scratch (loses font weight variation) |
| Spacing / radii / sizes | static `AppSpacing.*`, `AppRadii.*`, `AppSizes.*` (theme-independent, usable in `const`) | raw numbers |
| No BuildContext (painters, tests) | pass colours in from the widget; `AppTypography.*` is fine | — |

Files: `app_colors.dart` (raw `AppPalette`, internal), `app_colors_extension.dart`, `app_typography.dart`, `app_spacing.dart`, `app_theme.dart` (wires all into `ThemeData`), `theme_context.dart` (getters), `theme.dart` (barrel).
`AppPalette` may only be imported inside `core/theme/` (and painters as a last resort).

### Text style ↔ textTheme map
| AppTypography | `context.text.` |
|---|---|
| displayL | displayLarge |
| headlineL / headlineM | headlineLarge / headlineMedium |
| titleL / titleM / titleS | titleLarge / titleMedium / titleSmall |
| bodyL / bodyM / bodyS | bodyLarge / bodyMedium / bodySmall |
| labelL / labelS | labelLarge / labelSmall |
| numeric | `AppTypography.numeric` (no Material slot) |

## Colours
| Token | Hex | ColorScheme / extension | Used for |
|---|---|---|---|
| sky | `#59CFEC` | `primary` | Primary CTA (Let's get started, Continue, Add to cart, Earn), active tab pill, stepper buttons |
| skyLight | `#A4E4F4` | — | Pressed/disabled CTA tint, Platinum accents |
| skySubtle | `#E0F5FB` | `primaryContainer` | Selected chips, light fills |
| pink | `#F2599F` | `secondary`, `appColors.link` | Links (Log in, Terms, Privacy), registration progress ring, resend timer, "Total points" |
| pinkLight | `#F893B8` | — | Points ring gradient end, donut progress art |
| pinkSubtle | `#FCEDF2` | `appColors.authGradientTop` | Auth/onboarding background gradient (top → white) |
| orange | `#FE7E1E` | `tertiary`, `appColors.badge` | New badge, "% off" discount badge, Rewards pill, notification count |
| orangeSubtle | `#FDECDE` | `appColors.homeHeader` | Home member header wash |
| purple | `#5D59A6` | `appColors.banner` | Promo banner background |
| ink | `#1A1A1A` | `onSurface` | Headings and body text |
| inkSecondary | `#8C8E93` | `onSurfaceVariant`, `appColors.textSecondary` | Hints, captions, +95 prefix, product code |
| inkDisabled | `#B8B9C1` | — | Disabled text, Earn (incomplete) |
| surface | `#FFFFFF` | `surface` | Cards, inputs, product detail card |
| background | `#F5F5F7` | `scaffoldBackgroundColor` | Home, Product detail, Rewards lower area |
| divider | `#EEF0F1` | `outlineVariant`, `appColors.ringTrack` | Ring track, tab track, dividers |
| tierSilver / tierGold / tierPlatinum | `#C9D4D5` / `#F9E3A0` / `#A4E4F4` | `appColors.tier*` | Tier ladder badges |
| success | `#7DC37A` | `appColors.success` | Completed challenge cue |
| error | `#E5484D` | `error` | Inline validation messages, error borders (not in designs — chosen for contrast) |

Sampled values are approximate (PDF render). If a screen looks off, re-sample from the PDF rather than eyeballing.

## Typography
- **Nunito** — headings and titles (screen titles, section headers, product names, card titles, numbers).
- **Nunito Sans** — body text (descriptions, inputs, hints, captions, button labels, badges).
- Fonts are **bundled** in `assets/fonts/` (variable TTFs, OFL licence) — not `google_fonts` — so first launch offline renders correctly. Weight is set through `FontVariation.weight` in `AppTypography`; always derive from a token so this isn't lost.
- Myanmar script isn't in Nunito; `fontFamilyFallback` uses the platform Myanmar font.

| Token | Family | Size / weight | Example |
|---|---|---|---|
| displayL | Nunito | 32 / 800 | "Round food for every mood", Welcome title |
| headlineL | Nunito | 28 / 800 | "Enter your phone number", "What's your name?" |
| headlineM | Nunito | 24 / 800 | "J' Donuts Rewards", "Coconut Donut" |
| titleL | Nunito | 20 / 700 | "Seasonal specials", "Popular" |
| titleM | Nunito | 16 / 700 | Challenge title, tier name, member name |
| titleS | Nunito | 14 / 700 | Product tile name |
| numeric | Nunito | 28 / 800 | 680,000, quantity, OTP digits |
| bodyL / bodyM / bodyS | Nunito Sans | 16 / 14 / 12, 400 | Inputs, descriptions, captions |
| labelL | Nunito Sans | 14 / 800, uppercase | CTA labels (LET'S GET STARTED, CONTINUE) |
| labelS | Nunito Sans | 11 / 700 | Badges (New, 50% off) |

Text must survive 1.3× text scale: no fixed-height text containers; use `maxLines` + `overflow` on tiles.

## Spacing, radii, sizes
- Spacing: 4-pt scale `AppSpacing.s1…s12` (4–48). Screen side padding `AppSpacing.screenHorizontal` (24).
- Radii: input 8, card 16, sheet 24, pill (buttons, tabs, badges, Rewards pill).
- Sizes: button height 48, input height 52, OTP box 44, progress ring 28, avatar 44.

## Component look (match the designs)
| Component | Look |
|---|---|
| Primary button | Full-width pill, `primary` fill, white `labelL` uppercase; disabled = `skyLight`; scale on press; morphs to loading |
| Text field | White fill, no visible border, radius 8; focus = `primary` 1.5 px border; error = `error` border + message below |
| Phone field | `+95` prefix in `onSurfaceVariant` inside the same field |
| OTP | 6 white boxes, radius 8; focus border `primary`; error shakes then clears |
| Progress ring | Top-right, `secondary` sweep over `outlineVariant` track; 100% morphs to a filled pink check |
| Auth background | Vertical gradient `authGradientTop` → `surface` |
| Product tile | White card radius 16, image top, `titleS` name, orange badge top-right |
| Badge | Orange pill, white `labelS` |
| Bottom nav | White bar; active item = sliding `primary` pill |
| Tabs (Rewards) | `outlineVariant` track; active = `primary` pill with white text |
| Points ring | `CustomPainter`, pink gradient sweep over `ringTrack`, sprinkle decoration optional |

Light theme only (designs have no dark mode) — documented as a known gap.
