<p align="center">
  <img src="scrola/assets/brainy_mascot.png" width="160" alt="Scrola Brainy Mascot" />
</p>

<h1 align="center">Scrola</h1>

<p align="center">
  <strong>Take Control of Your Scroll.</strong><br>
  <em>A gamified digital wellbeing and screen-time management companion for Android built with Flutter.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android_8.0+_(API_26--34)-black?style=for-the-badge&logo=android&logoColor=%233DDC84" alt="Platform" />
  <img src="https://img.shields.io/badge/Flutter-3.41.4-black?style=for-the-badge&logo=flutter&logoColor=%2302569B" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.11.1-black?style=for-the-badge&logo=dart&logoColor=%230175C2" alt="Dart" />
  <img src="https://img.shields.io/badge/Theme-Black_&_Orange-black?style=for-the-badge&color=%23FF6B24" alt="Theme" />
  <img src="https://img.shields.io/badge/License-MIT-black?style=for-the-badge" alt="License" />
</p>

---

## 💡 Overview

**Scrola** transforms mindless short-form video consumption into an engaging, gamified journey toward digital health. By harnessing native Android Accessibility capabilities, Scrola precisely detects and tallies reels and shorts watched across **Instagram Reels**, **YouTube Shorts**, **Facebook Reels**, and **Snapchat Spotlight**.

With an interactive real-time floating overlay, automated feed blocking, and an expressive 3D companion named **Brainy**, Scrola makes you mindful of your scrolling habits and rewards you for taking back control.

> ### 🎨 Core Design Principle
> **"Black dominates, orange guides. No purple."**  
> Pure black canvases (`#101010`), subtle card elevations (`#242424`), and vibrant orange accents (`#FF6B24`) strictly reserved for active states, progress, and key actions.

---

## ⚡ Key Features

- **🎯 Short-Form Feed Detection & Tracking**  
  Uses native Android Accessibility Services to accurately detect when you are inside vertical short-form video feeds vs. standard feeds, with temporal debouncing to eliminate duplicate counts.

- **🪟 Interactive Floating Overlay**  
  A draggable HUD rendered directly over Instagram, YouTube, and other apps (`SYSTEM_ALERT_WINDOW`). Displays live counts (`24 / 40`), remaining quota, and changes from orange to amber (80% limit) and red (limit reached). Tap to collapse into a mini widget.

- **🧠 3D Mascot & Evolution System ("Brainy")**  
  An original interactive character that mirrors your scrolling habits in real time:
  - **Happy:** Healthy habits, well below daily goals (<70% of limit).
  - **Focused:** Active during distraction-free Focus sessions.
  - **Tired:** Droopy eyelids when binge-scrolling (≥85% of limit).
  - **Celebrating:** Joyful celebration when daily goals are achieved and streaks maintained.  
  *Brainy evolves as you earn XP—progressing from Curious Spark (Lv 1) to Curious Cortex (Lv 4) and evolving at Level 5.*

- **🛑 Automated Limit Enforcement & Feed Blocking**  
  When your daily limit is hit or when Focus Mode is running, Scrola automatically triggers `GLOBAL_ACTION_BACK` accompanied by distinct tactile vibration patterns, breaking the hypnotic scroll loop.

- **⏱️ Focus Mode (Distraction-Free Sessions)**  
  Configurable 25-minute Pomodoro timers that enforce zero-scroll rules across all supported platforms, rewarding you with +30 XP upon completion.

- **📳 Tactile Haptic Language (`HapticService`)**  
  A unified haptic feedback hierarchy:
  - `Subtle`: Navigation, tabs, segmented controls, slider ticks.
  - `Light`: Card taps, platform item selections, chip presses.
  - `Medium`: Primary buttons and toggle switches.
  - `Heavy`: Focus session locks, warnings, and limit breaches.

---

## 🏗️ Architecture & Data Flow

```mermaid
flowchart TD
    subgraph "Target Apps (Instagram, YouTube, Facebook, Snapchat)"
        A[User scrolls short-form video]
    end

    subgraph "Native Android Layer (Kotlin)"
        B[ScrolaAccessibilityService] -->|Detects Feed & Debounces Swipe| C[ScrolaDataManager]
        B -->|Limit Reached or Focus Active| D[Feed Block: GLOBAL_ACTION_BACK + Haptic Alert]
        C -->|Updates Real-time HUD| E[ScrolaOverlayService (Floating Pill)]
        B -->|Broadcasts Event| F[MainActivity EventSink]
    end

    subgraph "Flutter Layer (Dart)"
        F -->|EventChannel| G[ScrolaNativeBridge]
        G --> H[TrackingService]
        H --> I[GamificationEngine & Mascot State]
        H --> J[StorageService (SharedPreferences)]
        H --> K[HomeScreen UI Reactive Update]
        L[FocusModeService] -->|MethodChannel: syncLimits| C
    end

    A --> B
```

---

## 🎨 Design System (v0.1)

### Color Palette

| Token | Hex Code | Role |
| :--- | :--- | :--- |
| **Primary Background** | `#101010` | Screen canvas & base surface |
| **Secondary Background** | `#191919` | Grouped containers & sections |
| **Card Surface** | `#242424` | Primary cards & bottom sheets |
| **Elevated Surface** | `#2B2B2B` | Modals & elevated badges |
| **Border** | `#353535` | Component outlines & dividers |
| **Primary Accent** | `#FF6B24` | Actions, active progress, selection |
| **Accent Highlight** | `#FF8A4C` | Gradients, badges, hover states |
| **Primary Text** | `#FFFFFF` | Headings, titles, key numbers |
| **Secondary Text** | `#A3A3A3` | Body copy, secondary descriptions |
| **Muted Text** | `#707070` | Timestamps & inactive labels |
| **Success** | `#36C98F` | Positive status ("On pace", "Tracking on") |
| **Warning** | `#FFC15A` | Approaching limit (80%+) |
| **Error** | `#FF5252` | Limit reached / locked |

### Typography Hierarchy

- **Display:** `Plus Jakarta Sans 800` · `56/56` · Key numbers (`24`)
- **Title:** `Plus Jakarta Sans 700` · `28/34` · Screen titles (`Today`, `Alex`)
- **Heading:** `Plus Jakarta Sans 700` · `18/24` · Section titles (`Platforms`, `Brain level`)
- **Body:** `Inter 500` · `15/22` · Paragraphs & stats
- **Label:** `Inter 600` · `12/16` (CAPS) · Status tags (`REELS TODAY`, `FOCUS`)

---

## 🛡️ Edge Cases & Resilience Engineering

Scrola is engineered to handle real-world Android edge cases seamlessly:

1. **Android 14 (API 34) Foreground Services:** Configured with `ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE` to prevent OS termination or `MissingForegroundServiceTypeException`.
2. **Back-Press Flood Prevention:** A 2-second timestamp cooldown prevents cascading `GLOBAL_ACTION_BACK` dispatches from exiting host apps.
3. **Background-to-Foreground State Sync:** `TrackingService.syncFromNative()` queries native counters on `AppLifecycleState.resumed`, ensuring reels watched while Scrola was in the background are immediately accounted for.
4. **Boundary-Constrained Dragging:** The floating overlay is strictly clamped to display bounds, preventing accidental flings off the screen edge.
5. **False Positive Filtering:** Specifically discriminates between Instagram Stories (`reel_viewer_container`) and vertical Reels (`clips_video_container`, `layout_clips_viewer`).

---

## 📁 Project Structure

```
scrola/
├── android/
│   └── app/src/main/
│       ├── AndroidManifest.xml
│       ├── res/xml/accessibility_service_config.xml
│       └── kotlin/com/example/scrola/
│           ├── MainActivity.kt                      # MethodChannel & EventChannel Bridge
│           └── service/
│               ├── ScrolaAccessibilityService.kt    # Native Accessibility Reel Tracker
│               ├── ScrolaOverlayService.kt          # Floating Window Manager HUD
│               └── ScrolaDataManager.kt             # Native Persistent Counter State
├── assets/
│   ├── scrola_app_icon.png                          # App Icon
│   ├── brainy_mascot.png                            # High-res 3D Brainy Mascot
│   └── brainy_silhouette.png                        # Level Evolution Silhouette
└── lib/
    ├── core/
    │   ├── theme/
    │   │   ├── app_colors.dart                      # Official Color Tokens
    │   │   ├── app_typography.dart                  # Plus Jakarta Sans & Inter
    │   │   └── app_motion.dart                      # Motion Curves & Durations
    │   └── services/
    │       ├── haptic_service.dart                  # Unified Haptic Engine
    │       ├── scrola_native_bridge.dart            # Native Kotlin ↔ Flutter Bridge
    │       ├── storage_service.dart                 # Local SharedPreferences Manager
    │       ├── tracking_service.dart                # Central State Coordinator
    │       ├── gamification_engine.dart             # XP, Levels & Mascot State
    │       └── focus_mode_service.dart              # Pomodoro Countdown & Lockdown
    ├── shared/
    │   └── widgets/
    │       └── platform_icon.dart                   # Authentic Platform Brand Vectors
    ├── features/
    │   └── home/presentation/
    │       ├── screens/home_screen.dart             # Scrola Home Dashboard
    │       └── widgets/
    │           ├── home_header.dart                 # Header & Tracking Status
    │           ├── hero_gauge_section.dart          # Circular Orbit Arc & 3D Brainy
    │           ├── session_stats_bar.dart           # 3-Column Session Metrics
    │           ├── platform_breakdown_section.dart  # 2x2 Platform Grid (IG, YT, FB, SC)
    │           ├── brain_level_card.dart            # Level 4 Curious Cortex Progress
    │           ├── streak_week_card.dart            # 7-Day Streak Timeline
    │           ├── focus_banner_card.dart           # 25-Min Focus Reset CTA
    │           └── scrola_bottom_nav.dart           # Frosted Glass Floating Nav Bar
    └── main.dart                                    # Application Root
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK:** `^3.11.1` (Tested on Flutter `3.41.4`)
- **Android SDK:** `minSdk = 26`, `compileSdk = 34`
- **Device:** Android device running Android 8.0 or newer.

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/aditya21030/Scrola.git
   cd Scrola/scrola
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run on connected device:**
   ```bash
   flutter run
   ```

4. **Build Release APK:**
   ```bash
   flutter build apk
   ```
   *The compiled APK will be located at:*  
   `scrola/build/app/outputs/flutter-apk/app-release.apk`

---

## 📱 Permissions Required

- **Accessibility Service:** Required to detect reel scroll gestures and enforce daily limits.
- **Display Over Other Apps (`SYSTEM_ALERT_WINDOW`):** Required for the real-time floating tracking overlay.
- **Foreground Service:** Required to keep the overlay active and responsive while browsing third-party apps.

---

<p align="center">
  Made with 🧡 by <strong>Aditya</strong>
</p>
