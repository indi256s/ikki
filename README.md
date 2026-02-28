# Ikki

A macOS menu bar app that nudges you to take micro-breaks — breathing, eye rest, blink resets — so you can actually keep working without grinding yourself down.

**macOS 14+ · Zero dependencies · No network · No telemetry**

---

## What it does

After a set work interval (25 minutes by default), Ikki fires a notification with three choices: start a break, snooze 5 minutes, or skip. If you start one, a small floating window appears with a guided break. When it's done, the work timer restarts automatically.

The breaks are short (20–75 seconds depending on the technique) and grounded in actual research:

- **Breathing** — Cyclic sighing (Stanford 2023), box breathing, or 4-7-8. A pulsing circle guides the pace.
- **20-20-20** — Look at something 6 meters away for 20 seconds. Reduces eye strain from close-focus work.
- **Blink reset** — 10 slow, deliberate blinks. Sounds trivial; makes a difference.
- **Focus shift** — Alternate between near and far focus, 5 rounds of 5 seconds each.

The break type is picked at random from whatever you have enabled in settings.

---

## Install

> No binary available yet — build from source.

**Requirements:** Xcode 15+, macOS 14+

```bash
git clone https://github.com/indi256s/ikki
open ikki/Ikki.xcodeproj
```

Build and run the `Ikki` scheme. The app lives in the menu bar with no dock icon.

---

## Settings

| Setting | Default |
|---|---|
| Work interval | 25 min (presets: 20, 25, 40, 52, or custom) |
| Break types | All enabled |
| Default breathing technique | Cyclic sighing |
| Sound effects | On |
| Launch at login | Off |

Global shortcut ⌥⌘B toggles the timer from anywhere (pause/resume, or start if idle).

---

## Architecture

Pure Swift, no external packages. Uses the `@Observable` macro for state (macOS 14+), SwiftUI for all views, and AppKit where SwiftUI can't reach (the floating break window is an `NSPanel`).

```
Ikki/
├── Models/          TimerState, BreakType, BreathingTechnique, EyeTechnique, TechniquePhase, BreakTechnique
├── Services/        TimerService, NotificationService, BreakWindowController, SoundService, LaunchAtLoginService
├── ViewModels/      MenuBarViewModel, BreakViewModel, SettingsViewModel
├── Views/
│   ├── Breaks/      BreakContainerView, BreathingBreakView, EyeBreakView, BlinkResetView, FocusShiftView
│   ├── Settings/    SettingsView
│   └── Components/  PulsingCircleView, CircularCountdownView, AnimatedEyeView, PhaseLabel
├── Theme/           AppColors, AppTypography, AppSpacing, AppAnimations
└── Utilities/       AppConstants, UserDefaultsKeys, GlobalShortcutManager
```

The timer uses wall-clock anchoring (`fireDate: Date`) so it survives App Nap and display sleep without drifting. Break phase timing uses the same approach — no floating-point accumulation.

Notification handling lives entirely in `AppDelegate`, which is the sole `UNUserNotificationCenterDelegate`. Settings are persisted to `UserDefaults` with typed keys; `launchAtLogin` reads from `SMAppService` directly rather than from UserDefaults, so it doesn't go stale if you remove the app from System Settings.

---

## Breathing technique specs

| Technique | Pattern | Cycles | Total |
|---|---|---|---|
| Cyclic sighing | 2s inhale · 1s inhale · 6s exhale | 5 | 45s |
| Box breathing | 4s inhale · 4s hold · 4s exhale · 4s hold | 4 | 64s |
| 4-7-8 | 4s inhale · 7s hold · 8s exhale | 3 | 57s |

---

## Eye technique specs

| Technique | Duration |
|---|---|
| 20-20-20 | 20s |
| Blink reset | 30s (10 blinks × 3s) |
| Focus shift | 50s (5 rounds × near/far 5s each) |

---

## What's not in here (yet)

- Tests — the PRD has specs for `TimerService`, `BreathingTechnique`, and `TimerState` unit tests but they haven't been written
- App icon
- Notarization / distribution
- iCloud sync for settings

---

## License

MIT
