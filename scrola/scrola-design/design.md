# Scrola design specification

Version 0.3. Product: Scrola, a digital wellbeing app for Android (Flutter). Tagline: **Take Control of Your Scroll.**

## 1. What is in this package

- `index.html`: gallery of every screen, grouped by flow. Open it first.
- `screens/`: every screen as standalone HTML (390 px wide phone frames), numbered in canvas order.
- `assets/mascot/`: Brainy as SVG. 8 moods, 12 evolution forms, 6 skins.
- `tokens.json`: colour, type, spacing, radius and motion tokens.

Covered: all 53 screens from the approved architecture, plus the automatic in-app guide, level up and evolution, 12 brain forms, authentication, the limit warning and limit reached flow, 5 modals and 7 app states.

All numbers, names ("Alex") and prices are sample data. Keep them out of production code. The screens are design prototypes, not Flutter code.

## 2. Principles

1. Black dominates. Orange guides: actions, progress, selection, key numbers.
2. No purple. Success, warning and error colours are used only for their meaning.
3. Solid surfaces by default. Glass and glow only for floating things (counter orbs, selected cards, celebrations).
4. Large expressive numbers. One clear primary action per screen.
5. Every motion and every haptic has a reason. Never vibrate while counting reels.
6. Copy is specific and never claims more than the app does. Brainy never scolds.

## 3. Colour

| Token | Hex | Use |
|---|---|---|
| bg.primary | #101010 | Screen background |
| bg.secondary | #191919 | Nav, sheets |
| surface.solid | #1A1A1A | Default card |
| surface.card | #242424 | Raised card |
| surface.elevated | #2B2B2B | Icon wells, pressed |
| border / border.subtle | #353535 / #2A2A2A | Inputs, card outlines |
| accent | #FF6B24 | Primary action, progress, selection |
| accent.highlight | #FF8A4C | Numbers, links, icons on dark |
| text.primary / secondary | #FFFFFF / #A3A3A3 | |
| text.muted | #707070 | Decoration only, fails contrast for small text |
| text.onAccent | #101010 | Text on orange. White on orange fails contrast. |
| success / warning / error | #36C98F / #FFC15A / #FF5252 | Semantic only |

Gradients are for hero areas only. Buttons and bars are solid orange. Glows are soft and low.

## 4. Typography

Plus Jakarta Sans for headings and numbers, Inter for body and data. Five levels. Tabular numerals for statistics.

| Level | Font | Size / line | Weight |
|---|---|---|---|
| Display | Plus Jakarta Sans | 56 / 56 (hero numbers up to 100) | 800 |
| Title | Plus Jakarta Sans | 28 to 32 / 34 to 38 | 800 |
| Heading | Plus Jakarta Sans | 18 / 24 | 700 |
| Body | Inter | 15 / 22 | 500 |
| Label | Inter | 11 to 13 / 16, caps for section labels | 600 |

## 5. Spacing, shape, depth

8 pt grid (8, 16, 24, 32, 48). Screen padding 20 to 24. Radius 12 chips, 20 to 24 cards, 28 to 44 hero cards and sheets, pill for buttons. Depth comes from surface colour and a 1 px border, not shadows. Touch targets 44 px or more. Primary button 54 to 60 px.

## 6. Components

- **Buttons:** primary solid orange with a dark label, secondary outline, destructive outline in red, disabled grey. No arrow icons inside buttons.
- **Inputs:** 54 px, radius 16. States: idle, focus (orange, with a soft ring), error (red with a message), ok (green with a tick).
- **Cards:** solid with a 1 px border. Selected: orange border with a faint glow and a check badge.
- **Toggle, segmented control, chips, progress ring and bar, platform tiles, medals.**
- **Bottom nav:** floating pill, 68 px, 5 tabs (Home, Insights, Battles, Brain, Profile).
- **Bottom sheets and modals:** 36 to 44 px top radius, grabber, dimmed and blurred background.
- **State patterns:** skeleton (shimmer) only if data takes over 300 ms, empty (Brainy plus one action), partial data (progress toward unlocking), error (what happened, what still works, retry), offline banner, permission-denied card.

### Floating counter (notch pill)

Black capsule at top centre. Brainy sits in the centre, reels watched on the left, reels left on the right. Compact 150 x 42, expanded 252 x 48. States: normal, 80% (amber, tired), limit reached (red pulse, sad). Position "Stick to top centre" or "Free". Android cannot draw inside the camera cutout. Build it as a native overlay (Kotlin, `TYPE_APPLICATION_OVERLAY`), read the display cutout insets and place the pill beside the cutout.

## 7. Mascot: Brainy

Original character: a rounded brain, orange, soft 3D look (key light top left, rim light, orange bounce, contact shadow). The SVGs here are stand-ins. Production: a Blender render exported to Rive with the same states.

Eight moods (one face rig): happy, excited, neutral, focused, tired, sad, sleepy, celebrating.

| Mood | Proposed trigger (to confirm) |
|---|---|
| Happy | Under 60% of the limit |
| Neutral | 60 to 80% |
| Tired | 80 to 100% |
| Sad | Over the limit |
| Focused | During a focus session |
| Sleepy | Detox, night block, tracking paused |
| Excited | Level up, streak milestone |
| Celebrating | Achievement, evolution, setup complete |

Twelve evolution forms: Sleepy Seed (Lv 1 to 2), Curious Cortex (3 to 5), Bright Mind (6 to 8), Sharp Genius (9 to 11), Explorer (12 to 14), Ninja Focus (15 to 17), Zen Master (18 to 20), Wizard (21 to 23), Astronaut (24 to 26), Storm Brain (27 to 29), Cosmic Mind (30 to 34), Royal Legend (35+). Skins (colour only): Classic, Ember, Golden, Frost, Mint, Midnight.

## 8. Motion

Ease-out `cubic-bezier(0.2, 0.8, 0.2, 1)` for entrances. Durations: 120 ms press, 240 ms toggles and sheets, 480 ms entrances (50 ms stagger), 600 ms notch drop and evolution pop, 1000 ms and up for rings, bars and counters. Pause off-screen animation. With Android "remove animations" on, swap movement for fades.

## 9. Haptics (one central HapticService)

| Level | Used for |
|---|---|
| 1 Subtle (selection click) | Nav, tabs, segmented controls, slider ticks |
| 2 Light | Buttons, toggles, the 80% heads up (one tap) |
| 3 Medium | Submit, emergency unlock, battle start, focus complete |
| 4 Celebratory (custom pattern) | Level up, evolution, achievement, battle win |
| Warning | Limit reached |
| Error | Swipe while locked (at most once per 2 s), invalid input |

No haptics at 50% or during normal reel counting. Settings: on/off and Light / Medium / Strong. Follow the system setting.

## 10. Key flows

**First run:** Splash, Welcome, Create account (or Log in, or Google then pick a username), How Scrola works, Platform selection, Accessibility explanation and setup, Overlay explanation and setup, Notifications, Tracking complete, Goal selection, Home. The automatic guide (8 spotlight steps) starts by itself once when Home first opens. It is not part of onboarding. Replay it from Profile, Help.

**Authentication:** Log in takes an email or a username plus a password, or Google. Create account asks for email, a unique username and a password. Username: 3 to 20 characters, letters, numbers, dot, underscore, checked live after a 400 ms pause, with suggestions when taken. A new Google user must pick a username before setup. Errors never reveal whether an account exists. Reset links expire in 30 minutes (proposal).

**Limit flow:** 50% quiet tag, no haptic. 80% amber pill and a banner from the notch, one light tap. Last 3 reels: three dots. 100%: warning haptic, Brainy drops from the notch into the Limit reached modal (Back to Scrola, Go home, Unlock for 5 min). Emergency unlock waits 30 s, ends the streak and uses 1 of 2 daily unlocks. Swiping while locked gives an error tap and the reel bounces back. Gentle mode shows the unlock link. Strict mode hides it.

## 11. Screen inventory

| Screen | File | Flow |
|---|---|---|
| Design system v0.3 | `screens/001-design-system-v0-3.html` | Scrola · Foundation & Home |
| 12 Home Dashboard · premium v2 (full scroll) | `screens/002-12-home-dashboard-premium-v2-full-scroll.html` | Scrola · Foundation & Home |
| 1 Splash | `screens/003-1-splash.html` | Permissions & setup (Screens 6–10) |
| 2 Welcome | `screens/004-2-welcome.html` | Permissions & setup (Screens 6–10) |
| 3 How Scrola Works | `screens/005-3-how-scrola-works.html` | Permissions & setup (Screens 6–10) |
| 4 Platform Selection | `screens/006-4-platform-selection.html` | Permissions & setup (Screens 6–10) |
| 5 Accessibility Permission | `screens/007-5-accessibility-permission.html` | Permissions & setup (Screens 6–10) |
| 6 Accessibility Setup | `screens/008-6-accessibility-setup.html` | Permissions & setup (Screens 6–10) |
| 7 Overlay Explanation | `screens/009-7-overlay-explanation.html` | Permissions & setup (Screens 6–10) |
| 8 Overlay Setup | `screens/010-8-overlay-setup.html` | Permissions & setup (Screens 6–10) |
| 9 Notification Permission | `screens/011-9-notification-permission.html` | Permissions & setup (Screens 6–10) |
| 10 Tracking Setup Complete | `screens/012-10-tracking-setup-complete.html` | Permissions & setup (Screens 6–10) |
| 11 Goal Selection | `screens/013-11-goal-selection.html` | Goal & Home tracking (Screens 11, 13–16) |
| 13 Platform Breakdown | `screens/014-13-platform-breakdown.html` | Goal & Home tracking (Screens 11, 13–16) |
| 14 Live Tracking | `screens/015-14-live-tracking.html` | Goal & Home tracking (Screens 11, 13–16) |
| 15 Daily Scroll History | `screens/016-15-daily-scroll-history.html` | Goal & Home tracking (Screens 11, 13–16) |
| 16 Reel Limit Setup | `screens/017-16-reel-limit-setup.html` | Goal & Home tracking (Screens 11, 13–16) |
| 17 Platform-wise Limits | `screens/018-17-platform-wise-limits.html` | Limits, status & floating overlay (Screens 17–21) |
| 18 Tracking Status | `screens/019-18-tracking-status.html` | Limits, status & floating overlay (Screens 17–21) |
| 19 Floating Overlay Setup | `screens/020-19-floating-overlay-setup.html` | Limits, status & floating overlay (Screens 17–21) |
| 20 Floating Overlay Preview | `screens/021-20-floating-overlay-preview.html` | Limits, status & floating overlay (Screens 17–21) |
| 21 Floating Overlay Settings | `screens/022-21-floating-overlay-settings.html` | Limits, status & floating overlay (Screens 17–21) |
| 22 Brain Overview | `screens/023-22-brain-overview.html` | Brain & gamification (Screens 22–26) |
| 23 Brain Evolution | `screens/024-23-brain-evolution.html` | Brain & gamification (Screens 22–26) |
| 24 Brain Collection | `screens/025-24-brain-collection.html` | Brain & gamification (Screens 22–26) |
| 25 Brain Details | `screens/026-25-brain-details.html` | Brain & gamification (Screens 22–26) |
| 26 XP & Level Progress | `screens/027-26-xp-level-progress.html` | Brain & gamification (Screens 22–26) |
| 27 Achievements | `screens/028-27-achievements.html` | Achievements, rewards & focus (Screens 27–31) |
| 28 Streak Calendar | `screens/029-28-streak-calendar.html` | Achievements, rewards & focus (Screens 27–31) |
| 29 Rewards | `screens/030-29-rewards.html` | Achievements, rewards & focus (Screens 27–31) |
| 30 Focus Dashboard | `screens/031-30-focus-dashboard.html` | Achievements, rewards & focus (Screens 27–31) |
| 31 Focus Session Setup | `screens/032-31-focus-session-setup.html` | Achievements, rewards & focus (Screens 27–31) |
| 32 Active Focus Session | `screens/033-32-active-focus-session.html` | Focus & scroll control (Screens 32–36) |
| 33 Blocking Dashboard | `screens/034-33-blocking-dashboard.html` | Focus & scroll control (Screens 32–36) |
| 34 Blocking Schedule | `screens/035-34-blocking-schedule.html` | Focus & scroll control (Screens 32–36) |
| 35 Blocking Settings | `screens/036-35-blocking-settings.html` | Focus & scroll control (Screens 32–36) |
| 36 Scroll Detox | `screens/037-36-scroll-detox.html` | Focus & scroll control (Screens 32–36) |
| 49 Profile | `screens/038-49-profile.html` | Profile, settings & monetisation (Screens 49–53) |
| 50 Edit Profile | `screens/039-50-edit-profile.html` | Profile, settings & monetisation (Screens 49–53) |
| 51 Settings | `screens/040-51-settings.html` | Profile, settings & monetisation (Screens 49–53) |
| 52 Notifications | `screens/041-52-notifications.html` | Profile, settings & monetisation (Screens 49–53) |
| 53 Subscription & Scrola Pro | `screens/042-53-subscription-scrola-pro.html` | Profile, settings & monetisation (Screens 49–53) |
| Guide 1 Intro | `screens/043-guide-1-intro.html` | Automatic in-app guide (first launch, after setup) |
| Guide 2 Your reels today | `screens/044-guide-2-your-reels-today.html` | Automatic in-app guide (first launch, after setup) |
| Guide 3 Every app, counted | `screens/045-guide-3-every-app-counted.html` | Automatic in-app guide (first launch, after setup) |
| Guide 4 Stay under it, level up | `screens/046-guide-4-stay-under-it-level-up.html` | Automatic in-app guide (first launch, after setup) |
| Guide 5 Need a break? | `screens/047-guide-5-need-a-break.html` | Automatic in-app guide (first launch, after setup) |
| Guide 6 Counter over your apps | `screens/048-guide-6-counter-over-your-apps.html` | Automatic in-app guide (first launch, after setup) |
| Guide 7 Find your way around | `screens/049-guide-7-find-your-way-around.html` | Automatic in-app guide (first launch, after setup) |
| Guide 8 You're ready | `screens/050-guide-8-you-re-ready.html` | Automatic in-app guide (first launch, after setup) |
| Level Up | `screens/051-level-up.html` | Level up and evolution (Brain Evolution Animation) |
| Evolution: ready | `screens/052-evolution-ready.html` | Level up and evolution (Brain Evolution Animation) |
| Evolution: evolving | `screens/053-evolution-evolving.html` | Level up and evolution (Brain Evolution Animation) |
| Evolution: reveal | `screens/054-evolution-reveal.html` | Level up and evolution (Brain Evolution Animation) |
| Evolution: complete | `screens/055-evolution-complete.html` | Level up and evolution (Brain Evolution Animation) |
| Brain forms (all 12) | `screens/056-brain-forms-all-12.html` | Level up and evolution (Brain Evolution Animation) |
| 37 Friends Dashboard | `screens/057-37-friends-dashboard.html` | Social and competition (Screens 37 to 41) |
| 38 Find Friends | `screens/058-38-find-friends.html` | Social and competition (Screens 37 to 41) |
| 39 Friend Profile | `screens/059-39-friend-profile.html` | Social and competition (Screens 37 to 41) |
| 40 Friends Leaderboard | `screens/060-40-friends-leaderboard.html` | Social and competition (Screens 37 to 41) |
| 41 Scroll Battles | `screens/061-41-scroll-battles.html` | Social and competition (Screens 37 to 41) |
| 42 Create Battle | `screens/062-42-create-battle.html` | Battles and challenges (Screens 42 to 45) |
| 43 Battle Details | `screens/063-43-battle-details.html` | Battles and challenges (Screens 42 to 45) |
| 44 Battle Results | `screens/064-44-battle-results.html` | Battles and challenges (Screens 42 to 45) |
| 45 Group Challenges | `screens/065-45-group-challenges.html` | Battles and challenges (Screens 42 to 45) |
| 46 Insights Dashboard | `screens/066-46-insights-dashboard.html` | Insights and reports (Screens 46 to 48) |
| 47 Weekly Report | `screens/067-47-weekly-report.html` | Insights and reports (Screens 46 to 48) |
| 48 Monthly Report | `screens/068-48-monthly-report.html` | Insights and reports (Screens 46 to 48) |
| Login | `screens/069-login.html` | Authentication: log in and create account |
| Login: wrong details | `screens/070-login-wrong-details.html` | Authentication: log in and create account |
| Create account | `screens/071-create-account.html` | Authentication: log in and create account |
| Create account: username taken | `screens/072-create-account-username-taken.html` | Authentication: log in and create account |
| Google sign-in: pick a username | `screens/073-google-sign-in-pick-a-username.html` | Authentication: log in and create account |
| Forgot password | `screens/074-forgot-password.html` | Authentication: forgot and reset password |
| Check your email | `screens/075-check-your-email.html` | Authentication: forgot and reset password |
| Reset password | `screens/076-reset-password.html` | Authentication: forgot and reset password |
| Password updated | `screens/077-password-updated.html` | Authentication: forgot and reset password |
| 1 Counter hits the limit | `screens/078-1-counter-hits-the-limit.html` | Limit reached: from the notch to the modal |
| 2 Brainy drops from the notch | `screens/079-2-brainy-drops-from-the-notch.html` | Limit reached: from the notch to the modal |
| 3 Limit reached (animated) | `screens/080-3-limit-reached-animated.html` | Limit reached: from the notch to the modal |
| 4 Unlock for 5 minutes | `screens/081-4-unlock-for-5-minutes.html` | Limit reached: from the notch to the modal |
| 5 Swipe while locked | `screens/082-5-swipe-while-locked.html` | Limit reached: from the notch to the modal |
| 1 Halfway: 50% | `screens/083-1-halfway-50.html` | Limit approaching: 50%, 80% and the last 3 reels |
| 2 Heads up: 80% | `screens/084-2-heads-up-80.html` | Limit approaching: 50%, 80% and the last 3 reels |
| 3 Heads up banner (animated) | `screens/085-3-heads-up-banner-animated.html` | Limit approaching: 50%, 80% and the last 3 reels |
| 4 Last 3 reels | `screens/086-4-last-3-reels.html` | Limit approaching: 50%, 80% and the last 3 reels |
| Modal: Battle invitation | `screens/087-modal-battle-invitation.html` | Modals and bottom sheets |
| Modal: Achievement unlocked | `screens/088-modal-achievement-unlocked.html` | Modals and bottom sheets |
| Modal: Log out | `screens/089-modal-log-out.html` | Modals and bottom sheets |
| Modal: Delete account | `screens/090-modal-delete-account.html` | Modals and bottom sheets |
| Modal: Permission explanation | `screens/091-modal-permission-explanation.html` | Modals and bottom sheets |
| State: Loading | `screens/092-state-loading.html` | App states: loading, empty, partial data, error |
| State: Empty (friends) | `screens/093-state-empty-friends.html` | App states: loading, empty, partial data, error |
| State: Partial data (insights) | `screens/094-state-partial-data-insights.html` | App states: loading, empty, partial data, error |
| State: Error | `screens/095-state-error.html` | App states: loading, empty, partial data, error |
| State: Offline | `screens/096-state-offline.html` | App states: offline, permission denied, empty history |
| State: Permission denied | `screens/097-state-permission-denied.html` | App states: offline, permission denied, empty history |
| State: Empty (history) | `screens/098-state-empty-history.html` | App states: offline, permission denied, empty history |

## 12. Review notes

Frosted cards became solid surfaces, glowing gradient buttons became solid orange, glows and decorative stars were removed, icon-row lists were replaced with comparisons and labelled diagrams, and filler copy was rewritten. Still worth a human pass: the repeated top glow and the shared Brainy pose on some screens.

## 13. Flutter implementation notes

Clean architecture (presentation, application, domain, data, platform). Riverpod or Bloc, GoRouter, Drift. Map `tokens.json` to a `ThemeExtension`. Brainy via Rive state machine. Charts and tick rings via `CustomPainter`. Native Kotlin for the Accessibility service, overlay, blocking and cutout insets. Accessibility: font scaling, 44 px targets, contrast, reduced motion. Test at 320 dp wide. Keep mock data in its own package.

## 14. Open items

1. Email verification code screen.
2. Home dashboard state at 80% of the limit.
3. Final 3D Brainy (Blender and Rive) and the Rive animation timings.
4. Play Store direction (A to D) and the remaining four screenshots in that style.
5. Replace sample data with real captures for store assets.
6. Test on small phones (320 dp).
7. Flutter implementation.
