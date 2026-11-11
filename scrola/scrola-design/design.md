# Scrola design specification

Version 0.2. Product: Scrola, a digital wellbeing app for Android (Flutter). Tagline: **Take Control of Your Scroll.**

## 1. What is in this package

- `screens/`: 41 high-fidelity screens as standalone HTML (390 px wide phone frames). Open any file in a browser.
- `index.html`: gallery of all screens.
- `assets/mascot/`: Brainy in 8 moods as SVG (flat stand-ins, see section 7).
- `tokens.json`: colour, type, spacing, radius and motion tokens.

Covered: screens 1 to 36 and 49 to 53. Not designed yet: 37 to 48 (Social and Insights), loading, empty, error, offline and permission-denied states, the 8 modals and bottom sheets.

All numbers, names ("Alex") and prices are sample data. Keep them out of production code.

## 2. Principles

1. Black dominates. Orange guides: actions, progress, selection, key numbers.
2. No purple. Success, warning and error colours are used only for their meaning.
3. Solid surfaces by default. Glass and glow are reserved for hero moments (Home hero, floating orbs, selected cards, celebration screens).
4. Large expressive numbers, one clear primary action per screen.
5. Every motion and haptic has a reason. Nothing loops without cause.
6. Copy is specific ("16 left. Easy day.") and never claims more than the app does.

## 3. Colour

| Token | Hex | Use |
|---|---|---|
| bg.primary | #101010 | Screen background |
| bg.secondary | #191919 | Nav bar, sheets |
| surface.solid | #1A1A1A | Default card |
| surface.card | #242424 | Raised card |
| surface.elevated | #2B2B2B | Icon wells, pressed |
| border | #353535 | Inputs, dividers on cards |
| border.subtle | #2A2A2A | Card outline |
| accent | #FF6B24 | Primary action, progress, selection |
| accent.highlight | #FF8A4C | Numbers, links, icons on dark |
| text.primary | #FFFFFF | |
| text.secondary | #A3A3A3 | |
| text.muted | #707070 | Decoration only, fails contrast for small text |
| text.onAccent | #101010 | Text on orange. White on orange fails contrast. |
| success / warning / error | #36C98F / #FFC15A / #FF5252 | Semantic only |

Gradients: only in hero areas (ring arcs, Focus card, level badge). Buttons and bars are solid orange. Glows are soft and low opacity.

## 4. Typography

Plus Jakarta Sans for headings and numbers, Inter for body and data. Five levels only. Use tabular numerals for all statistics.

| Level | Font | Size / line | Weight |
|---|---|---|---|
| Display | Plus Jakarta Sans | 56 / 56 (hero numbers up to 100) | 800 |
| Title | Plus Jakarta Sans | 28 to 32 / 34 to 38 | 800 |
| Heading | Plus Jakarta Sans | 18 / 24 | 700 |
| Body | Inter | 15 / 22 | 500 |
| Label | Inter | 11 to 13 / 16, caps for section labels | 600 |

## 5. Spacing, shape, depth

- 8 pt grid: 8, 16, 24, 32, 48. Screen padding 20 to 24. Card padding 14 to 18.
- Radius: 12 chips and tiles, 20 to 24 cards, 28 hero cards and sheets, pill for buttons and nav.
- Depth comes from surface colour and a 1 px border, not shadows. Shadows only on the floating nav and the floating counter.
- Touch targets 44 px or larger. Primary button 56 to 60 px high.

## 6. Components

- **Primary button:** solid #FF6B24, #101010 label, pill, no arrow icon. Secondary: outline #353535. Link: #A3A3A3 underline.
- **Card:** solid surface.solid with a 1 px border. Selected state: 1 to 2 px orange border and a faint orange glow, check badge on the right.
- **Toggle:** 52 x 32, orange when on, dark knob. A pulsing orange ring marks the toggle the user must tap in permission guides.
- **Segmented control and chips:** pill, orange fill for the active item.
- **Progress:** ring (tick marks plus glowing arc with knob), bar (6 to 10 px), 11 step onboarding bar.
- **Platform tile:** rounded square in the platform's brand colour with a generic reel glyph. Do not use real brand logos without permission.
- **Bottom nav:** floating pill, 68 px high, 16 px side margin. Five tabs: Home, Insights, Battles, Brain, Profile. Active tab is an orange circle with a dark icon.
- **Medals (achievements):** done = orange gradient disc, in progress = partial ring, locked = grey with lock.
- **Permission guide pattern:** explain why, show exactly what is and is not read, then a mock of the Android settings screen with the target toggle ringed, numbered steps, a "Waiting for permission" status and an "Open Settings" button.

### Floating counter (notch pill)

- Black capsule at top centre. Brainy sits in the exact centre, reels watched on the left, reels remaining (orange) on the right. Tap opens Scrola.
- Compact: 150 x 42, numbers only. Expanded: 252 x 48, adds "watched" and "left" labels.
- Position: "Stick to top centre" (default) or "Free" (drag).
- Android cannot draw inside the camera cutout. Build it as a native overlay (Kotlin, `TYPE_APPLICATION_OVERLAY`), read the display cutout insets, and place the pill beside the cutout. On phones without a cutout it sits below the status bar.
- Never vibrate while counting reels.

## 7. Mascot: Brainy

Original character, a rounded brain in orange with a soft 3D look (radial light, rim light, bounce light, ground shadow). The SVGs here are flat stand-ins. The production character should be a Blender render exported to Rive, with the same eight states.

| State | Proposed trigger (to confirm) |
|---|---|
| Happy | Under 60% of today's limit |
| Neutral | 60 to 80% |
| Tired | 80 to 100% |
| Sad | Over the limit |
| Focused | During a focus session |
| Sleepy | Detox, night block |
| Excited | Level up, streak milestone |
| Celebrating | Achievement, evolution, setup complete |

Evolution stages: Sleepy Seed (Lv 1 to 2), Curious Cortex (3 to 5), Bright Mind (6 to 9), Sharp Genius (10 to 14), Zen Master (15+). Skins: Classic, Ember, Golden, Frost, Mint, Midnight.

## 8. Motion

Easing: `cubic-bezier(0.2, 0.8, 0.2, 1)` for entrances, ease-in `(0.4, 0, 1, 1)` for exits.

| Token | ms | Use |
|---|---|---|
| press | 120 | Button feedback |
| standard | 240 | Toggles, tabs, sheets |
| enter | 480 | Card entrance, 50 ms stagger |
| data | 1000+ | Rings, bars, charts, counters |

Present in the prototypes: count-up numbers, ring draw, bar fill, staggered card entrance, idle breathing and blinking, floating orbs, pulsing "tap here" and "live" dots, chart bars growing. Pause off-screen animation, cap work at 60 fps, and swap movement for fades when Android "remove animations" is on.

## 9. Haptics (one central HapticService)

| Level | Feel | Used for |
|---|---|---|
| 1 Subtle | Selection click | Bottom nav, tabs, segmented controls, slider ticks, pull to refresh |
| 2 Light | Light impact | Buttons, toggles |
| 3 Medium | Medium impact / success | Form submit, blocking on, battle start, focus complete |
| 4 Celebratory | Custom multi-step pattern | Achievement, level up, evolution, victory |

Also: warning notification at the daily limit, error notification on failures, subtle feedback on a battle loss. Settings has an on/off switch and Light / Medium / Strong intensity. Follow the system haptic setting.

## 10. Screen inventory

| # | Screen | File | Section |
|---|---|---|---|
| 1 | Splash | `screens/01-splash.html` | Onboarding |
| 2 | Welcome | `screens/02-welcome.html` | Onboarding |
| 3 | How Scrola Works | `screens/03-how-scrola-works.html` | Onboarding |
| 4 | Platform Selection | `screens/04-platform-selection.html` | Onboarding |
| 5 | Accessibility Permission Explanation | `screens/05-accessibility-permission-explanation.html` | Onboarding |
| 6 | Accessibility Permission Setup | `screens/06-accessibility-permission-setup.html` | Onboarding |
| 7 | Overlay Permission Explanation | `screens/07-overlay-permission-explanation.html` | Onboarding |
| 8 | Overlay Permission Setup | `screens/08-overlay-permission-setup.html` | Onboarding |
| 9 | Notification Permission | `screens/09-notification-permission.html` | Onboarding |
| 10 | Tracking Setup Complete | `screens/10-tracking-setup-complete.html` | Onboarding |
| 11 | Goal Selection | `screens/11-goal-selection.html` | Onboarding |
| 12 | Home Dashboard | `screens/12-home-dashboard.html` | Home and tracking |
| 13 | Platform Breakdown | `screens/13-platform-breakdown.html` | Home and tracking |
| 14 | Live Tracking | `screens/14-live-tracking.html` | Home and tracking |
| 15 | Daily Scroll History | `screens/15-daily-scroll-history.html` | Home and tracking |
| 16 | Reel Limit Setup | `screens/16-reel-limit-setup.html` | Home and tracking |
| 17 | Platform-wise Limits | `screens/17-platform-wise-limits.html` | Home and tracking |
| 18 | Tracking Status | `screens/18-tracking-status.html` | Home and tracking |
| 19 | Floating Overlay Setup | `screens/19-floating-overlay-setup.html` | Floating overlay |
| 20 | Floating Overlay Preview | `screens/20-floating-overlay-preview.html` | Floating overlay |
| 21 | Floating Overlay Settings | `screens/21-floating-overlay-settings.html` | Floating overlay |
| 22 | Brain Overview | `screens/22-brain-overview.html` | Brain and gamification |
| 23 | Brain Evolution | `screens/23-brain-evolution.html` | Brain and gamification |
| 24 | Brain Collection | `screens/24-brain-collection.html` | Brain and gamification |
| 25 | Brain Details | `screens/25-brain-details.html` | Brain and gamification |
| 26 | XP and Level Progress | `screens/26-xp-and-level-progress.html` | Brain and gamification |
| 27 | Achievements | `screens/27-achievements.html` | Brain and gamification |
| 28 | Streak Calendar | `screens/28-streak-calendar.html` | Brain and gamification |
| 29 | Rewards | `screens/29-rewards.html` | Brain and gamification |
| 30 | Focus Dashboard | `screens/30-focus-dashboard.html` | Focus and scroll control |
| 31 | Focus Session Setup | `screens/31-focus-session-setup.html` | Focus and scroll control |
| 32 | Active Focus Session | `screens/32-active-focus-session.html` | Focus and scroll control |
| 33 | Blocking Dashboard | `screens/33-blocking-dashboard.html` | Focus and scroll control |
| 34 | Blocking Schedule | `screens/34-blocking-schedule.html` | Focus and scroll control |
| 35 | Blocking Settings | `screens/35-blocking-settings.html` | Focus and scroll control |
| 36 | Scroll Detox | `screens/36-scroll-detox.html` | Focus and scroll control |
| 49 | Profile | `screens/49-profile.html` | Profile and settings |
| 50 | Edit Profile | `screens/50-edit-profile.html` | Profile and settings |
| 51 | Settings | `screens/51-settings.html` | Profile and settings |
| 52 | Notifications (settings) | `screens/52-notifications-settings.html` | Profile and settings |
| 53 | Subscription and Scrola Pro | `screens/53-subscription-and-scrola-pro.html` | Profile and settings |

## 11. Review notes: what was changed to avoid a generic look

- Frosted glass cards everywhere became solid surfaces. Glass stays on floating orbs only.
- Glowing gradient buttons became solid orange. Arrow icons removed from buttons.
- Orange glows and shadows halved. Decorative stars removed, rings kept only on Splash and the setup-complete screen. Background glow reduced on utility screens.
- The repeated "three icon rows" pattern replaced on the accessibility and overlay explanations with a "sees / never reads" comparison and a labelled counter diagram.
- Filler copy rewritten to be specific.

Still worth a human design pass: the repeated top-glow background, uniform title weight, and the identical Brainy pose on many screens.

## 12. Flutter implementation notes

- Architecture: presentation, application, domain, data, platform. Riverpod or Bloc, GoRouter, Drift (SQLite).
- Theme: map `tokens.json` into a `ThemeExtension`. Build the components in section 6 as widgets before screens.
- Mascot: Rive state machine with the eight states. Charts and tick rings: `CustomPainter`.
- Native Kotlin: Accessibility service (reel detection), overlay service, app blocking, usage of cutout insets.
- Accessibility: respect font scaling, 44 px targets, contrast (see colour notes), reduced motion. The UI must not overflow on small phones, so test at 320 dp wide.
- Keep mock data in a separate package. Real tracking data must never be faked.

## 13. Open items

1. Screens 37 to 48 and the 8 modals and bottom sheets.
2. Loading, empty, error, offline and permission-denied states for every data screen.
3. Real 3D mascot and Rive file.
4. Final Pro pricing and store copy.
5. Confirm Brainy mood thresholds and the evolution levels.
