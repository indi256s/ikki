# Ikki — macOS Menu-Bar Micro-Break App

## Product Requirements Document & Implementation Plan

> **Target:** macOS 14+ (Sonoma) | **Language:** Swift 5.9+ | **UI:** SwiftUI + AppKit interop
> **Dependencies:** None (zero external packages) | **Network:** None | **Telemetry:** None

---

## 1. Project Structure

```
Ikki/
├── Ikki.xcodeproj/
│   └── project.pbxproj
├── Ikki/
│   ├── IkkiApp.swift                    # @main entry, MenuBarExtra, AppDelegate
│   ├── Info.plist                        # LSUIElement=true, bundle metadata
│   ├── Ikki.entitlements                 # App Sandbox, user-notifications
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/
│   │   │   └── Contents.json
│   │   └── Contents.json
│   │
│   ├── Models/
│   │   ├── TimerState.swift              # Work-timer state machine
│   │   ├── BreakType.swift               # Break category enum + metadata
│   │   ├── BreathingTechnique.swift       # Breathing technique definitions
│   │   ├── EyeTechnique.swift            # Eye exercise definitions
│   │   └── TechniquePhase.swift          # Phase model (inhale/hold/exhale/etc.)
│   │
│   ├── Services/
│   │   ├── TimerService.swift            # Core countdown timer logic
│   │   ├── NotificationService.swift     # UNUserNotificationCenter wrapper
│   │   ├── SoundService.swift            # NSSound playback
│   │   └── LaunchAtLoginService.swift    # SMAppService / LaunchAgent management
│   │
│   ├── ViewModels/
│   │   ├── MenuBarViewModel.swift        # Menu-bar state, timer display
│   │   ├── BreakViewModel.swift          # Break window orchestration
│   │   └── SettingsViewModel.swift       # Settings binding + persistence
│   │
│   ├── Views/
│   │   ├── MenuBarView.swift             # MenuBarExtra content view
│   │   ├── BreakWindow/
│   │   │   ├── BreakWindowController.swift   # NSPanel host for floating window
│   │   │   ├── BreakContainerView.swift      # Root break view (routes to technique)
│   │   │   ├── BreathingBreakView.swift      # Pulsing circle + phase label + countdown
│   │   │   ├── EyeBreakView.swift            # 20-20-20 circular countdown
│   │   │   ├── BlinkResetView.swift          # Animated eye blink guide
│   │   │   └── FocusShiftView.swift          # Near/far alternating indicator
│   │   │
│   │   ├── Settings/
│   │   │   └── SettingsView.swift            # Settings window (tabbed)
│   │   │
│   │   └── Components/
│   │       ├── PulsingCircleView.swift       # Breathing animation (smooth circular pulse)
│   │       ├── CircularCountdownView.swift   # Ring countdown timer
│   │       ├── AnimatedEyeView.swift         # Blink animation (open/close)
│   │       └── PhaseLabel.swift              # "Inhale" / "Hold" / "Exhale" label
│   │
│   ├── Theme/
│   │   ├── AppColors.swift               # Adaptive color palette (Light/Dark)
│   │   ├── AppTypography.swift           # SF Pro Rounded type scale
│   │   ├── AppSpacing.swift              # 8pt grid spacing + corner radii
│   │   └── AppAnimations.swift           # Spring animation presets
│   │
│   ├── Utilities/
│   │   ├── Constants.swift               # App-wide constants
│   │   ├── UserDefaultsKeys.swift        # @AppStorage key strings
│   │   └── GlobalShortcutManager.swift   # ⌥⌘B global hotkey via NSEvent
│   │
│   └── Sounds/
│       ├── break_start.aiff              # System-compatible break start chime
│       └── break_end.aiff                # System-compatible break end chime
│
└── IkkiTests/
    ├── TimerServiceTests.swift
    ├── BreathingTechniqueTests.swift
    └── TimerStateTests.swift
```

---

## 2. File Specifications

### 2.1 Entry Point

#### `IkkiApp.swift`
**Purpose:** App entry point. Configures menu-bar-only app with no dock icon.

```
@main struct IkkiApp: App
```

- Uses `MenuBarExtra` (macOS 13+) with `Window` style for the popover menu.
- Holds `@StateObject` references to `MenuBarViewModel`.
- Registers `AppDelegate` via `@NSApplicationDelegateAdaptor` for notification setup.
- Opens `SettingsView` via `Settings` scene.
- Opens break window via `BreakWindowController` (programmatic NSPanel).

**Key types:**
```swift
@main
struct IkkiApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var menuBarVM = MenuBarViewModel()
    var body: some Scene { ... }
}

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching(_:)
    func userNotificationCenter(_:didReceive:withCompletionHandler:)
}
```

---

### 2.2 Models

#### `TimerState.swift`
**Purpose:** State machine for the work timer lifecycle.

```swift
enum TimerState: Equatable {
    case idle                        // No timer running
    case running(remaining: TimeInterval)  // Counting down
    case paused(remaining: TimeInterval)   // User paused
    case fired                       // Timer reached zero, notification sent
    case onBreak(remaining: TimeInterval)  // Break in progress
}
```

#### `BreakType.swift`
**Purpose:** Enumeration of available break categories.

```swift
enum BreakType: String, CaseIterable, Codable, Identifiable {
    case breathing
    case eye         // 20-20-20
    case blinkReset
    case focusShift

    var id: String { rawValue }
    var displayName: String { ... }
    var defaultDurationSeconds: Int { ... }
}
```

#### `BreathingTechnique.swift`
**Purpose:** Definitions of breathing exercises with phase timing.

```swift
enum BreathingTechnique: String, CaseIterable, Codable, Identifiable {
    case cyclicSighing   // 2s inhale + 1s inhale → 6s exhale, 5 cycles
    case boxBreathing    // 4-4-4-4, 4 cycles
    case fourSevenEight  // 4-7-8, 3 cycles

    var id: String { rawValue }
    var displayName: String { ... }
    var phases: [TechniquePhase] { ... }
    var cycleCount: Int { ... }
    var totalDurationSeconds: Int { ... }
}
```

#### `EyeTechnique.swift`
**Purpose:** Definitions of eye exercises.

```swift
enum EyeTechnique: String, CaseIterable, Codable, Identifiable {
    case twentyTwentyTwenty   // Look 6m away, 20s
    case blinkReset           // 10 slow blinks
    case focusShift           // near/far 5s × 5 rounds

    var id: String { rawValue }
    var displayName: String { ... }
    var totalDurationSeconds: Int { ... }
    var instruction: String { ... }
}
```

#### `TechniquePhase.swift`
**Purpose:** Single phase within a breathing cycle.

```swift
struct TechniquePhase: Identifiable, Equatable {
    let id = UUID()
    let label: String          // "Inhale", "Hold", "Exhale"
    let durationSeconds: Double
    let animationScale: CGFloat // 1.0 = expanded, 0.3 = contracted
}
```

---

### 2.3 Services

#### `TimerService.swift`
**Purpose:** Core countdown logic. Publishes state changes via Combine.

```swift
@Observable
final class TimerService {
    private(set) var state: TimerState = .idle
    private var timer: Timer?
    private var fireDate: Date?

    func start(workMinutes: Int)     // Start countdown
    func pause()                      // Pause countdown
    func resume()                     // Resume from pause
    func stop()                       // Reset to idle
    func snooze(minutes: Int)         // Add minutes and restart
    func startBreak(duration: TimeInterval) // Transition to onBreak
    func endBreak()                   // Transition to idle

    var remainingFormatted: String { ... }  // "23m" or "1:05"
    var progress: Double { ... }            // 0.0–1.0
}
```

**Implementation notes:**
- Uses `Timer.scheduledTimer(withTimeInterval: 1.0, ...)` on main RunLoop.
- Stores `fireDate` to survive app nap (recalculates remaining on wake).
- Publishes via `@Observable` macro (macOS 14+).

#### `NotificationService.swift`
**Purpose:** Request notification permission and deliver local notifications.

```swift
final class NotificationService {
    static let shared = NotificationService()

    func requestAuthorization()
    func scheduleBreakNotification()        // "Time for a break!"
    func cancelPendingNotifications()

    // Notification actions
    static let startBreakActionID = "START_BREAK"
    static let skipActionID = "SKIP"
    static let snoozeActionID = "SNOOZE_5"
    static let categoryID = "BREAK_REMINDER"
}
```

**Implementation notes:**
- Registers `UNNotificationCategory` with three actions: Start Break, Skip, Snooze 5 min.
- `AppDelegate` conforms to `UNUserNotificationCenterDelegate` to handle action responses.

#### `SoundService.swift`
**Purpose:** Play system-compatible sounds for break start/end.

```swift
final class SoundService {
    static let shared = SoundService()

    func playBreakStart()
    func playBreakEnd()

    private func play(named: String)  // NSSound(named:)?.play()
}
```

**Implementation notes:**
- Falls back to `NSSound.beep()` if custom sound files are missing.
- Respects `UserDefaults` sound-enabled setting.

#### `LaunchAtLoginService.swift`
**Purpose:** Manage start-at-login via SMAppService (macOS 13+).

```swift
final class LaunchAtLoginService {
    static let shared = LaunchAtLoginService()

    var isEnabled: Bool { get }
    func enable() throws
    func disable() throws
}
```

**Implementation notes:**
- Uses `SMAppService.mainApp.register()` / `.unregister()`.
- Requires `com.apple.developer.login-item` entitlement.

---

### 2.4 ViewModels

#### `MenuBarViewModel.swift`
**Purpose:** Drives the menu-bar icon label and popover content.

```swift
@Observable
final class MenuBarViewModel {
    let timerService = TimerService()
    let notificationService = NotificationService.shared
    let soundService = SoundService.shared

    var selectedPresetMinutes: Int          // 20, 25, 40, 52, or custom
    var customMinutes: Int                  // User-defined interval

    var menuBarTitle: String { ... }        // "23m" or "Ikki"

    func startTimer()
    func pauseTimer()
    func resumeTimer()
    func stopTimer()
    func snooze()
    func startBreak()
    func skipBreak()

    // Called by AppDelegate when notification action is tapped
    func handleNotificationAction(_ actionID: String)
}
```

#### `BreakViewModel.swift`
**Purpose:** Controls break window content, technique animation, and auto-close.

```swift
@Observable
final class BreakViewModel {
    let breakType: BreakType
    let breathingTechnique: BreathingTechnique?
    let eyeTechnique: EyeTechnique?

    private(set) var currentPhaseIndex: Int = 0
    private(set) var currentCycle: Int = 1
    private(set) var phaseTimeRemaining: Double = 0
    private(set) var totalTimeRemaining: Double = 0
    private(set) var isComplete: Bool = false

    var currentPhase: TechniquePhase? { ... }
    var animationScale: CGFloat { ... }

    func startBreak()
    func dismiss()

    // Internal
    private func advancePhase()
    private func completeCycle()
}
```

#### `SettingsViewModel.swift`
**Purpose:** Two-way binding to UserDefaults for all settings.

```swift
@Observable
final class SettingsViewModel {
    // NOTE: @AppStorage cannot be used inside @Observable classes.
    // Use plain stored properties with didSet → UserDefaults persistence.

    // Work timer
    var workIntervalMinutes: Int = 25 {
        didSet { UserDefaults.standard.set(workIntervalMinutes, forKey: UserDefaultsKeys.workIntervalMinutes) }
    }
    var customIntervalMinutes: Int = 30 {
        didSet { UserDefaults.standard.set(customIntervalMinutes, forKey: UserDefaultsKeys.customIntervalMinutes) }
    }

    // Break types enabled
    var breathingEnabled: Bool = true {
        didSet { UserDefaults.standard.set(breathingEnabled, forKey: UserDefaultsKeys.breathingEnabled) }
    }
    var eyeBreakEnabled: Bool = true {
        didSet { UserDefaults.standard.set(eyeBreakEnabled, forKey: UserDefaultsKeys.eyeBreakEnabled) }
    }
    var blinkResetEnabled: Bool = true {
        didSet { UserDefaults.standard.set(blinkResetEnabled, forKey: UserDefaultsKeys.blinkResetEnabled) }
    }
    var focusShiftEnabled: Bool = true {
        didSet { UserDefaults.standard.set(focusShiftEnabled, forKey: UserDefaultsKeys.focusShiftEnabled) }
    }

    // Defaults
    var defaultBreathingTechnique: String = BreathingTechnique.cyclicSighing.rawValue {
        didSet { UserDefaults.standard.set(defaultBreathingTechnique, forKey: UserDefaultsKeys.defaultBreathingTechnique) }
    }
    var soundEnabled: Bool = true {
        didSet { UserDefaults.standard.set(soundEnabled, forKey: UserDefaultsKeys.soundEnabled) }
    }
    var launchAtLogin: Bool = false {
        didSet { setLaunchAtLogin(launchAtLogin) }
    }

    init() {
        let d = UserDefaults.standard
        workIntervalMinutes = d.object(forKey: UserDefaultsKeys.workIntervalMinutes) as? Int ?? 25
        customIntervalMinutes = d.object(forKey: UserDefaultsKeys.customIntervalMinutes) as? Int ?? 30
        breathingEnabled = d.object(forKey: UserDefaultsKeys.breathingEnabled) as? Bool ?? true
        eyeBreakEnabled = d.object(forKey: UserDefaultsKeys.eyeBreakEnabled) as? Bool ?? true
        blinkResetEnabled = d.object(forKey: UserDefaultsKeys.blinkResetEnabled) as? Bool ?? true
        focusShiftEnabled = d.object(forKey: UserDefaultsKeys.focusShiftEnabled) as? Bool ?? true
        defaultBreathingTechnique = d.string(forKey: UserDefaultsKeys.defaultBreathingTechnique) ?? BreathingTechnique.cyclicSighing.rawValue
        soundEnabled = d.object(forKey: UserDefaultsKeys.soundEnabled) as? Bool ?? true
        launchAtLogin = d.object(forKey: UserDefaultsKeys.launchAtLogin) as? Bool ?? false
    }

    func setLaunchAtLogin(_ enabled: Bool)
}
```

---

### 2.5 Views

#### `MenuBarView.swift`
**Purpose:** Content of the menu-bar popover/menu.

- Shows current timer state (idle / running countdown / paused).
- Preset buttons: 20m, 25m, 40m, 52m, Custom.
- Start / Pause / Resume / Stop controls.
- Quick-access to Settings.
- Quit button.

#### `BreakWindowController.swift`
**Purpose:** Manages a floating `NSPanel` for break overlays.

```swift
final class BreakWindowController {
    static let shared = BreakWindowController()

    func showBreak(type: BreakType, technique: Any?)  // Any? = BreathingTechnique or EyeTechnique
    func dismiss()

    private var panel: NSPanel?
}
```

**Implementation notes:**
- `NSPanel` with `.floating`, `.nonactivatingPanel` style mask.
- Level: `NSWindow.Level.floating`.
- `panel.isMovableByWindowBackground = true`.
- Hosts SwiftUI `BreakContainerView` via `NSHostingView`.

#### `BreakContainerView.swift`
**Purpose:** Root break view. Routes to correct technique view.

```swift
struct BreakContainerView: View {
    @State var viewModel: BreakViewModel
    var onDismiss: () -> Void
    var body: some View { ... }
}
```

#### `BreathingBreakView.swift`
**Purpose:** Animated breathing guide with pulsing circle, phase label, countdown.

- Displays `PulsingCircleView` that scales based on `viewModel.animationScale`.
- Shows `PhaseLabel` with current phase name ("Inhale", "Hold", "Exhale").
- Shows per-phase countdown and cycle counter ("Cycle 2 of 5").
- Total remaining time at bottom.

#### `EyeBreakView.swift`
**Purpose:** 20-20-20 rule overlay.

- Instruction text: "Look at something 6 meters (20 feet) away".
- `CircularCountdownView` showing 20-second countdown.
- Auto-dismisses when complete.

#### `BlinkResetView.swift`
**Purpose:** Guided blink exercise.

- `AnimatedEyeView` that opens/closes on a 3-second cycle.
- Counter: "Blink 3 of 10".
- Total remaining time.

#### `FocusShiftView.swift`
**Purpose:** Near/far focus alternation.

- Alternating labels: "Focus NEAR (arm's length)" ↔ "Focus FAR (6m away)".
- 5-second timer per focus, 5 rounds.
- `CircularCountdownView` for each 5-second segment.

#### `SettingsView.swift`
**Purpose:** App settings window with tabs.

- **General tab:** Work interval preset selector, custom interval stepper, sound toggle, launch at login toggle.
- **Breaks tab:** Toggles for each break type, default breathing technique picker.
- Uses `Form` layout with `TabView`.

---

### 2.6 Components

#### `PulsingCircleView.swift`
**Purpose:** Smooth circular pulsing animation for breathing exercises.

```swift
struct PulsingCircleView: View {
    var scale: CGFloat           // 0.3 (contracted) to 1.0 (expanded)
    var phaseDuration: Double    // Animation duration for current phase
    var body: some View { ... }  // Circle with .scaleEffect and .animation(.easeInOut)
}
```

#### `CircularCountdownView.swift`
**Purpose:** Ring-shaped countdown timer.

```swift
struct CircularCountdownView: View {
    var totalSeconds: Double
    var remainingSeconds: Double
    var body: some View { ... }  // Circle stroke trim from progress
}
```

#### `AnimatedEyeView.swift`
**Purpose:** Eye icon that animates open/close for blink exercise.

```swift
struct AnimatedEyeView: View {
    var isOpen: Bool
    var body: some View { ... }  // SF Symbol eye.fill / eye.slash.fill with transition
}
```

#### `PhaseLabel.swift`
**Purpose:** Animated phase name display.

```swift
struct PhaseLabel: View {
    var text: String             // "Inhale", "Hold", "Exhale"
    var body: some View { ... }  // Text with content transition
}
```

---

### 2.7 Utilities

#### `Constants.swift`
```swift
enum Constants {
    static let defaultWorkMinutes = 25
    static let snoozeMinutes = 5
    static let presetMinutes = [20, 25, 40, 52]
    static let breakWindowWidth: CGFloat = 400
    static let breakWindowHeight: CGFloat = 400
    static let menuBarPopoverWidth: CGFloat = 280
}
```

#### `UserDefaultsKeys.swift`
```swift
enum UserDefaultsKeys {
    static let workIntervalMinutes = "workIntervalMinutes"
    static let customIntervalMinutes = "customIntervalMinutes"
    static let breathingEnabled = "breathingEnabled"
    static let eyeBreakEnabled = "eyeBreakEnabled"
    static let blinkResetEnabled = "blinkResetEnabled"
    static let focusShiftEnabled = "focusShiftEnabled"
    static let defaultBreathingTechnique = "defaultBreathingTechnique"
    static let soundEnabled = "soundEnabled"
    static let launchAtLogin = "launchAtLogin"
}
```

---

## 3. Data Flow Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                         IkkiApp (@main)                         │
│  ┌─────────────────┐    ┌──────────────┐    ┌───────────────┐   │
│  │  MenuBarExtra    │    │   Settings    │    │ AppDelegate   │   │
│  │  (system tray)   │    │   (window)    │    │ (notif. dlg.) │   │
│  └────────┬─────────┘    └──────┬───────┘    └───────┬───────┘   │
└───────────┼──────────────────────┼───────────────────┼───────────┘
            │                      │                   │
            ▼                      ▼                   │
   ┌─────────────────┐   ┌─────────────────┐           │
   │ MenuBarViewModel │   │SettingsViewModel│           │
   │                  │   │ (@AppStorage)   │           │
   │ • menuBarTitle   │   │                 │           │
   │ • startTimer()   │   │ • workInterval  │           │
   │ • handleAction() │◄──│ • breakToggles  │           │
   └────────┬─────────┘   │ • soundEnabled  │           │
            │              └─────────────────┘           │
            │                                            │
            ▼                                            │
   ┌─────────────────┐                                   │
   │  TimerService    │                                   │
   │  (@Observable)   │                                   │
   │                  │    ┌──────────────────────────┐   │
   │ state: TimerState│───▶│ NotificationService      │   │
   │ • start()        │    │ • scheduleBreakNotif()   │◄──┘
   │ • pause()        │    │ • UNNotificationAction   │
   │ • snooze()       │    └──────────────────────────┘
   │ • startBreak()   │
   └────────┬─────────┘
            │
            │ state == .fired → user taps "Start Break"
            ▼
   ┌─────────────────────┐
   │ BreakWindowController│
   │ (NSPanel - floating) │
   │                      │
   │ hosts SwiftUI:       │
   │  BreakContainerView  │
   │    │                 │
   │    ├─▶ BreathingBreakView ──▶ PulsingCircleView
   │    ├─▶ EyeBreakView       ──▶ CircularCountdownView
   │    ├─▶ BlinkResetView     ──▶ AnimatedEyeView
   │    └─▶ FocusShiftView     ──▶ CircularCountdownView
   │                      │
   └──────────┬───────────┘
              │
              ▼
   ┌─────────────────┐    ┌─────────────────┐
   │  BreakViewModel  │    │  SoundService   │
   │  (@Observable)   │───▶│  (NSSound)      │
   │                  │    └─────────────────┘
   │ • currentPhase   │
   │ • animationScale │
   │ • startBreak()   │
   │ • dismiss()      │
   └──────────────────┘

   ┌──────────────────────────────────────────┐
   │           UserDefaults                   │
   │  ┌──────────────────────────────────┐    │
   │  │ workIntervalMinutes: Int         │    │
   │  │ customIntervalMinutes: Int       │    │
   │  │ breathingEnabled: Bool           │    │
   │  │ eyeBreakEnabled: Bool            │    │
   │  │ blinkResetEnabled: Bool          │    │
   │  │ focusShiftEnabled: Bool          │    │
   │  │ defaultBreathingTechnique: String│    │
   │  │ soundEnabled: Bool               │    │
   │  │ launchAtLogin: Bool              │    │
   │  └──────────────────────────────────┘    │
   └──────────────────────────────────────────┘
```

### Data Flow Summary

1. **User selects preset** → `MenuBarViewModel.startTimer()` → `TimerService.start(workMinutes:)` → state becomes `.running`.
2. **Timer ticks** → `TimerService` updates `state.remaining` every 1s → `MenuBarViewModel.menuBarTitle` recomputes → menu bar label updates.
3. **Timer fires** → `TimerService` sets state to `.fired` → `NotificationService.scheduleBreakNotification()` → system notification appears.
4. **User taps notification action** → `AppDelegate.userNotificationCenter(_:didReceive:)` → `MenuBarViewModel.handleNotificationAction()`:
   - "Start Break" → selects a random enabled break type → `BreakWindowController.showBreak()` → `BreakViewModel.startBreak()`.
   - "Skip" → `TimerService.start()` (restarts work timer).
   - "Snooze 5 min" → `TimerService.snooze(minutes: 5)`.
5. **Break runs** → `BreakViewModel` drives phase transitions → animation views update → on completion, `BreakWindowController.dismiss()` → `TimerService.endBreak()` → auto-restarts work timer.
6. **Settings changes** → `@AppStorage` writes to `UserDefaults` → read by `MenuBarViewModel` / `TimerService` on next cycle.

---

## 4. Breathing Technique Specifications

### Cyclic Sighing (Stanford 2023)
```
Phase 1: Inhale (nose)     → 2.0s  → scale 0.7
Phase 2: Inhale (nose)     → 1.0s  → scale 1.0
Phase 3: Exhale (mouth)    → 6.0s  → scale 0.3
─────────────────────────────────────
Cycle duration: 9.0s
Cycles: 5
Total: 45s
```

### Box Breathing (Navy SEALs)
```
Phase 1: Inhale            → 4.0s  → scale 1.0
Phase 2: Hold              → 4.0s  → scale 1.0
Phase 3: Exhale            → 4.0s  → scale 0.3
Phase 4: Hold              → 4.0s  → scale 0.3
─────────────────────────────────────
Cycle duration: 16.0s
Cycles: 4
Total: 64s
```

### 4-7-8 Breathing
```
Phase 1: Inhale            → 4.0s  → scale 1.0
Phase 2: Hold              → 7.0s  → scale 1.0
Phase 3: Exhale            → 8.0s  → scale 0.3
─────────────────────────────────────
Cycle duration: 19.0s
Cycles: 3
Total: 57s
```

---

## 5. Eye Technique Specifications

### 20-20-20 Rule
```
Instruction: "Look at something 20 feet (6 meters) away"
Duration: 20 seconds
Visual: Circular countdown ring
```

### Blink Reset
```
Instruction: "Blink slowly and fully"
Blinks: 10
Pace: 3 seconds per blink (1.5s close + 1.5s open)
Total: 30 seconds
Visual: Animated eye icon
```

### Focus Shift
```
Phase A: "Focus NEAR — hold a finger at arm's length" → 5s
Phase B: "Focus FAR — look at something 6m away"      → 5s
Rounds: 5
Total: 50 seconds
Visual: Circular countdown per phase, label swap
```

---

## 6. Task List — Ordered Implementation Steps

Each task is atomic and has a clear "done" criterion.

### Phase 1: Project Scaffold

- [ ] **T01 — Create Xcode project**
  Create a new macOS App project named `Ikki` with SwiftUI lifecycle, deployment target macOS 14.0, bundle ID `com.ikki.app`. Set `LSUIElement = true` in Info.plist. Create the folder structure from Section 1.
  **Done when:** `xcodebuild -scheme Ikki -configuration Debug build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO` succeeds with zero errors.

- [ ] **T02 — Add Constants, UserDefaultsKeys, and Theme**
  Implement `Constants.swift`, `UserDefaultsKeys.swift`, and the full Theme/ directory: `AppColors.swift`, `AppTypography.swift`, `AppSpacing.swift`, `AppAnimations.swift` as specified in Sections 2.7 and 9.1–9.5. Add `AccentColor` and `AccentSoft` color sets to `Assets.xcassets`.
  **Done when:** Project compiles; `AppColors.accent` resolves in both Light and Dark appearance.

### Phase 2: Models

- [ ] **T03 — Implement TechniquePhase model**
  Create `TechniquePhase.swift` as specified.
  **Done when:** Unit test verifies `TechniquePhase` can be instantiated with label, duration, and scale.

- [ ] **T04 — Implement BreakType enum**
  Create `BreakType.swift` with all four cases and computed properties.
  **Done when:** Unit test verifies `BreakType.allCases.count == 4` and each case returns valid `displayName` and `defaultDurationSeconds > 0`.

- [ ] **T05 — Implement BreathingTechnique enum**
  Create `BreathingTechnique.swift` with three techniques. Each must return correct `phases` array and `totalDurationSeconds` matching Section 4 specs.
  **Done when:** Unit test verifies:
  - `cyclicSighing.totalDurationSeconds == 45`
  - `boxBreathing.totalDurationSeconds == 64`
  - `fourSevenEight.totalDurationSeconds == 57`
  - Phase counts: 3, 4, 3 respectively.

- [ ] **T06 — Implement EyeTechnique enum**
  Create `EyeTechnique.swift` as specified.
  **Done when:** Unit test verifies `totalDurationSeconds` for each technique matches Section 5.

### Phase 3: Services

- [ ] **T07 — Implement TimerService**
  Create `TimerService.swift` with `@Observable`, `Timer`-based countdown, state machine transitions per Section 2.3.
  **Done when:** Unit test verifies: start → running, pause → paused, resume → running, stop → idle, snooze adds time, timer fires → .fired state.

- [ ] **T08 — Implement NotificationService**
  Create `NotificationService.swift`. Register category with 3 actions. Implement `scheduleBreakNotification()`.
  **Done when:** Project compiles; manual test shows notification with 3 action buttons.

- [ ] **T09 — Implement SoundService**
  Create `SoundService.swift`. Add placeholder `.aiff` sound files to `Sounds/` (or use `NSSound(named: .purr)`).
  **Done when:** Project compiles; `playBreakStart()` produces audible sound.

- [ ] **T10 — Implement LaunchAtLoginService**
  Create `LaunchAtLoginService.swift` using `SMAppService`.
  **Done when:** Project compiles; `isEnabled` property returns a boolean.

### Phase 4: ViewModels

- [ ] **T11 — Implement MenuBarViewModel**
  Create `MenuBarViewModel.swift`. Wire `TimerService`, format `menuBarTitle`, implement action handlers.
  **Done when:** Unit test verifies `menuBarTitle` returns "25m" when timer is at 25 minutes, "Ikki" when idle.

- [ ] **T12 — Implement BreakViewModel**
  Create `BreakViewModel.swift`. Implement phase-by-phase progression for breathing techniques, cycle counting, auto-complete.
  **Done when:** Unit test verifies: starting a cyclic sighing break progresses through 3 phases × 5 cycles, then `isComplete == true`.

- [ ] **T13 — Implement SettingsViewModel**
  Create `SettingsViewModel.swift` with `@AppStorage` bindings.
  **Done when:** Project compiles; changing a value persists to `UserDefaults`.

### Phase 5: UI Components

- [ ] **T14 — Implement PulsingCircleView**
  Create the 3-layer breathing animation circle as specified in Section 9.9: inner fill (radial gradient), ring stroke (accent @ 25%), outer glow (blurred, accent @ 8%). Each layer scales with staggered delay (0, 0.05, 0.1s). Uses `.timingCurve(0.4, 0.0, 0.2, 1.0)` — NOT `.easeInOut`. Respects `@Environment(\.accessibilityReduceMotion)`.
  **Done when:** Preview shows layered circle scaling between 0.3 and 1.0 with organic, staggered spring animation. Glow layer visible around edges.

- [ ] **T15 — Implement CircularCountdownView**
  Create ring countdown. Uses `Circle().trim(from:to:)` with stroke style.
  **Done when:** Preview shows ring that depletes as `remainingSeconds` decreases.

- [ ] **T16 — Implement AnimatedEyeView**
  Create eye blink animation using SF Symbols (`eye` / `eye.slash`).
  **Done when:** Preview shows eye toggling open/close.

- [ ] **T17 — Implement PhaseLabel**
  Create animated text label with `.contentTransition(.numericText())`.
  **Done when:** Preview shows label text changing with animation.

### Phase 6: Break Views

- [ ] **T18 — Implement BreathingBreakView**
  Compose `PulsingCircleView` + `PhaseLabel` + cycle counter + total countdown. Bind to `BreakViewModel`.
  **Done when:** View displays and animates through a full breathing technique cycle in preview.

- [ ] **T19 — Implement EyeBreakView**
  Show instruction text + `CircularCountdownView` for 20s.
  **Done when:** View displays 20-second countdown with instruction text.

- [ ] **T20 — Implement BlinkResetView**
  Show `AnimatedEyeView` + blink counter (X of 10).
  **Done when:** View displays animated eye with blink counter.

- [ ] **T21 — Implement FocusShiftView**
  Show alternating near/far labels + `CircularCountdownView` per 5s segment.
  **Done when:** View alternates between near/far with countdown.

- [ ] **T22 — Implement BreakContainerView**
  Route to correct break view based on `BreakType`. Add dismiss button.
  **Done when:** View renders correct sub-view for each `BreakType`.

- [ ] **T23 — Implement BreakWindowController**
  Create `NSPanel` wrapper per Section 9.4 spec: `.hudWindow` material, `.behindWindow` blending, `cornerRadius: 20`, `hasShadow: true`, `titlebarAppearsTransparent: true`, 420×420. Host SwiftUI `BreakContainerView` inside `NSVisualEffectView` via `NSHostingView`. Implement appear animation (fade + scale 0.92→1 spring) and dismiss animation (scale 1→0.95 + fade easeIn 0.15s) per Section 9.5. Add 3pt accent-colored progress bar at top of break window.
  **Done when:** Calling `showBreak()` opens a floating vibrancy-backed window with spring appear animation; `dismiss()` plays exit animation then closes. Window has visible backdrop blur and rounded corners.

### Phase 7: Menu Bar & Settings UI

- [ ] **T24 — Implement MenuBarView**
  Create popover content per Section 9.7 layout mockup: timer countdown (32pt light monospacedDigit), linear progress bar (accent color), capsule preset buttons (6pt corners, accent fill for selected), full-width accent Start button (10pt corners), ghost Stop/Reset buttons, divider, Settings (⌘,) and Quit (⌘Q) row with SF Symbols. All text uses `AppTypography`, all spacing uses `AppSpacing`, all colors use `AppColors`. Width: 280pt.
  **Done when:** Menu bar popover matches Section 9.7 mockup; buttons trigger `MenuBarViewModel` methods; keyboard shortcuts work.

- [ ] **T25 — Implement SettingsView**
  Tabbed settings form: General (interval, sound, login) + Breaks (toggles, default technique).
  **Done when:** Settings window opens from menu bar; all toggles read/write `@AppStorage`.

### Phase 8: App Integration

- [ ] **T26 — Wire IkkiApp entry point**
  Connect `MenuBarExtra` to `MenuBarView` + `MenuBarViewModel`. Set up `AppDelegate` for notification handling. Wire notification actions to `MenuBarViewModel.handleNotificationAction()`. Connect break flow: timer fires → notification → start break → window.
  **Done when:** Full flow works: start timer → wait → notification → tap Start Break → break window opens → break completes → window closes → timer restarts.

- [ ] **T27 — Add entitlements**
  Configure `Ikki.entitlements`: App Sandbox = YES, `com.apple.security.user-notifications` = YES.
  **Done when:** App builds and runs with sandbox enabled.

### Phase 9: Keyboard Shortcuts & Accessibility

- [ ] **T28 — Implement GlobalShortcutManager**
  Create `GlobalShortcutManager.swift`. Register ⌥⌘B global hotkey via `NSEvent.addGlobalMonitorForEvents(matching: .keyDown)`. Wire to `MenuBarViewModel.toggleTimer()`. Add `Esc` → dismiss to break window via `.keyboardShortcut(.cancelAction)`.
  **Done when:** Pressing ⌥⌘B toggles timer start/pause from any app; Esc closes break window.

- [ ] **T29 — Add accessibility support**
  Add `@Environment(\.accessibilityReduceMotion)` checks to all animated views. Replace spring animations with `.none` when reduced motion is on. Replace breathing circle scale animation with opacity fade. Add `.accessibilityLabel()` and `.accessibilityHint()` to all interactive controls. Ensure VoiceOver can navigate the menu bar popover and break window.
  **Done when:** Enabling "Reduce motion" in System Settings makes all animations instant; VoiceOver reads all controls.

### Phase 10: Testing & Validation

- [ ] **T30 — Write unit tests**
  Create `TimerServiceTests.swift`, `BreathingTechniqueTests.swift`, `TimerStateTests.swift` with tests specified in task done criteria above.
  **Done when:** `xcodebuild test -scheme Ikki -configuration Debug CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO` passes all tests.

- [ ] **T31 — App Nap resilience**
  In `TimerService`, on timer tick recalculate remaining from `fireDate` instead of decrementing. This ensures the timer survives macOS App Nap.
  **Done when:** Timer shows correct remaining time after system sleep/wake.

- [ ] **T32 — Final build validation**
  Run full build and confirm zero warnings, zero errors.
  **Done when:** `xcodebuild -scheme Ikki -configuration Debug build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO` exits with status 0 and `** BUILD SUCCEEDED **` in output.

---

## 7. Build Validation Command

```bash
xcodebuild -scheme Ikki -configuration Debug build \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO
```

Run tests:
```bash
xcodebuild test -scheme Ikki -configuration Debug \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO
```

---

## 8. Key Design Decisions

| Decision | Rationale |
|---|---|
| `@Observable` over `ObservableObject` | macOS 14+ target; cleaner syntax, no `@Published` boilerplate |
| `MenuBarExtra` over legacy `NSStatusItem` | Native SwiftUI API (macOS 13+); simpler lifecycle |
| `NSPanel` for break window | Floating, non-activating behavior not achievable with SwiftUI `Window` |
| `Timer` + `fireDate` over `DispatchSourceTimer` | Simpler API; `fireDate` approach handles App Nap gracefully |
| `SMAppService` over `LaunchAgent` plist | Modern API (macOS 13+); no manual plist management |
| `UserDefaults` / `@AppStorage` | Sufficient for flat settings; no need for Core Data or file-based config |
| No Combine / async-await in timer | `Timer.scheduledTimer` on main run loop is simplest for 1s ticks; `@Observable` handles reactivity |
| Zero dependencies | Maximizes reliability; all features achievable with system frameworks |
| SF Pro Rounded for UI | Matches Apple/Raycast friendly aesthetic; system font = zero bundle size |
| Spring animations over easeInOut | Spring physics feel alive and natural; easeInOut feels flat/robotic |
| `NSVisualEffectView` + `.ultraThinMaterial` | Native vibrancy = instant Raycast/Apple feel |
| 8pt spacing grid | Apple HIG standard; prevents inconsistent spacing |
| Global keyboard shortcut | Keyboard-first UX like Raycast; power users expect this |

---

## 9. Visual Design System

> **Design goal:** Raycast/Apple-native feel — vibrancy, spring animations, SF Pro Rounded, 8pt grid, keyboard-first.

### 9.1 Color Palette

Adaptive colors that work in both Light and Dark mode using semantic `NSColor` / SwiftUI `Color` mappings.

```swift
// Theme/AppColors.swift
enum AppColors {
    // MARK: – Accent (teal-based wellness palette)
    static let accent      = Color("AccentColor")       // Asset catalog: Light #0D9488 / Dark #2DD4BF
    static let accentSoft  = Color("AccentSoft")         // Light #CCFBF1 / Dark #0D3D38

    // MARK: – Surfaces
    static let surface     = Color(nsColor: .windowBackgroundColor)  // System adaptive
    static let surfaceHover = Color(nsColor: .selectedContentBackgroundColor).opacity(0.08)

    // MARK: – Text hierarchy
    static let textPrimary   = Color(nsColor: .labelColor)           // Full opacity label
    static let textSecondary = Color(nsColor: .secondaryLabelColor)  // 55% opacity
    static let textTertiary  = Color(nsColor: .tertiaryLabelColor)   // 35% opacity

    // MARK: – Semantic
    static let breatheRing   = Color("AccentColor")     // Breathing circle fill
    static let eyeRing       = Color.blue.opacity(0.8)  // Eye exercise accent
    static let warningOrange = Color.orange              // Snooze/alert

    // MARK: – Break window gradient (subtle radial behind breathing circle)
    static let breakGradientStart = Color("AccentColor").opacity(0.15)
    static let breakGradientEnd   = Color.clear
}
```

**Asset Catalog entries required:**
| Color Name | Light | Dark |
|---|---|---|
| `AccentColor` | `#0D9488` (teal-600) | `#2DD4BF` (teal-400) |
| `AccentSoft` | `#CCFBF1` (teal-100) | `#0D3D38` (teal-950) |

### 9.2 Typography

All text uses **SF Pro Rounded** for the friendly, approachable feel that matches Apple Health and Raycast.

```swift
// Theme/AppTypography.swift
enum AppTypography {
    // Menu bar popover
    static let popoverTitle     = Font.system(.title3, design: .rounded, weight: .semibold)   // 15pt
    static let popoverBody      = Font.system(.body, design: .rounded, weight: .regular)      // 13pt
    static let popoverCaption   = Font.system(.caption, design: .rounded, weight: .medium)    // 11pt

    // Break window
    static let breakHeadline    = Font.system(size: 28, weight: .bold, design: .rounded)
    static let breakPhaseLabel  = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let breakCountdown   = Font.system(size: 48, weight: .light, design: .rounded).monospacedDigit()
    static let breakCaption     = Font.system(size: 14, weight: .medium, design: .rounded)

    // Settings
    static let settingsSection  = Font.system(.headline, design: .rounded, weight: .semibold)
    static let settingsBody     = Font.system(.body, design: .rounded, weight: .regular)
}
```

**Type scale (8pt grid aligned):**
| Role | Size | Weight | Line height |
|---|---|---|---|
| Break countdown | 48pt | Light | 56pt |
| Break headline | 28pt | Bold | 36pt |
| Break phase | 22pt | Semibold | 28pt |
| Popover title | 15pt | Semibold | 20pt |
| Body | 13pt | Regular | 18pt |
| Caption | 11pt | Medium | 14pt |

### 9.3 Spacing & Layout (8pt Grid)

```swift
// Theme/AppSpacing.swift
enum AppSpacing {
    static let xxs: CGFloat = 2
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 12
    static let lg:  CGFloat = 16
    static let xl:  CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}

enum AppCorners {
    static let sm: CGFloat = 6
    static let md: CGFloat = 10
    static let lg: CGFloat = 14
    static let xl: CGFloat = 20   // Break window corners
}
```

### 9.4 Materials & Vibrancy

```
┌─ Menu Bar Popover ──────────────────────────┐
│  Background: .ultraThinMaterial              │
│  Corner radius: 10pt (system default)        │
│  Shadow: system MenuBarExtra handles this    │
└──────────────────────────────────────────────┘

┌─ Break Window (NSPanel) ────────────────────┐
│  NSVisualEffectView:                         │
│    material: .hudWindow                      │
│    blendingMode: .behindWindow               │
│    state: .active                            │
│  Corner radius: 20pt (panel.styleMask)       │
│  Shadow: NSShadow offset(0,4) blur(20)       │
│          color: black @ 0.25 opacity          │
│  Level: .floating                             │
│  Size: 420 × 420 (not 400 — room for padding)│
└──────────────────────────────────────────────┘
```

**BreakWindowController NSPanel setup:**
```swift
let panel = NSPanel(
    contentRect: NSRect(x: 0, y: 0, width: 420, height: 420),
    styleMask: [.titled, .closable, .fullSizeContentView, .nonactivatingPanel],
    backing: .buffered,
    defer: false
)
panel.isFloatingPanel = true
panel.level = .floating
panel.titlebarAppearsTransparent = true
panel.titleVisibility = .hidden
panel.isMovableByWindowBackground = true
panel.backgroundColor = .clear
panel.hasShadow = true

// Vibrancy background
let visualEffect = NSVisualEffectView()
visualEffect.material = .hudWindow
visualEffect.blendingMode = .behindWindow
visualEffect.state = .active
visualEffect.wantsLayer = true
visualEffect.layer?.cornerRadius = 20
visualEffect.layer?.masksToBounds = true
panel.contentView = visualEffect

// Host SwiftUI inside the visual effect view
let hostingView = NSHostingView(rootView: breakContainerView)
hostingView.translatesAutoresizingMaskIntoConstraints = false
visualEffect.addSubview(hostingView)
// pin hostingView to all edges of visualEffect
```

### 9.5 Animation Specifications

**All UI transitions use spring physics, NOT easeInOut.**

```swift
// Theme/AppAnimations.swift
enum AppAnimations {
    // Breathing circle scale — slow, gentle, calming
    static let breathe = Animation.timingCurve(0.4, 0.0, 0.2, 1.0, duration: 0) // duration set per phase

    // UI element appear/disappear — Raycast-like snappy spring
    static let snappy = Animation.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0)

    // Subtle state change (button highlight, toggle)
    static let micro = Animation.spring(response: 0.2, dampingFraction: 0.9, blendDuration: 0)

    // Break window appear
    static let windowAppear = Animation.spring(response: 0.45, dampingFraction: 0.8, blendDuration: 0)

    // Break window dismiss
    static let windowDismiss = Animation.easeIn(duration: 0.15)

    // Phase label text swap
    static let phaseSwap = Animation.spring(response: 0.3, dampingFraction: 0.75, blendDuration: 0)
}
```

**Break window appear/dismiss choreography:**
```
APPEAR:
  1. Panel alpha: 0 → 1     (0.3s)
  2. Content scale: 0.92 → 1  (spring, response 0.45)
  3. Content offset Y: 8 → 0  (spring, same timing)

DISMISS:
  1. Content scale: 1 → 0.95  (easeIn 0.15s)
  2. Panel alpha: 1 → 0       (easeIn 0.15s)
  3. Remove panel after 0.15s
```

**Breathing animation — NOT a simple scale:**
```
PulsingCircleView layers:
  Layer 1 (inner):  Circle filled with accent color, scales per phase
  Layer 2 (ring):   Circle stroked, 2pt, accent @ 30% opacity, scales with 0.05 delay
  Layer 3 (glow):   Circle filled with accent @ 10%, blurred 20pt, scales with 0.1 delay

  → Creates a layered, organic "breathing" feel (not a flat circle popping)
```

**Reduced motion support:**
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// In views:
.animation(reduceMotion ? .none : AppAnimations.snappy, value: someState)

// For breathing circle: replace scale animation with opacity fade
```

### 9.6 Keyboard Shortcuts

```swift
// Utilities/KeyboardShortcuts.swift
enum AppKeyboardShortcuts {
    // Global (works even when app is not focused)
    static let toggleTimer = KeyEquivalent("b")   // ⌥⌘B — toggle start/pause
    // Note: Registered via NSEvent.addGlobalMonitorForEvents

    // Break window
    // Esc → dismiss (built-in via .keyboardShortcut(.cancelAction))
    // Space → pause/resume technique

    // Menu bar popover
    // ⌘, → open Settings (standard macOS convention)
    // ⌘Q → quit
}
```

**Global hotkey registration (in AppDelegate):**
```swift
NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
    if event.modifierFlags.contains([.option, .command]) && event.keyCode == 11 { // B key
        // toggle timer
    }
}
```

### 9.7 Menu Bar Popover Layout

```
┌─────────────────── 280pt ───────────────────┐
│  .ultraThinMaterial background               │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │  ● Ikki          [IDLE state]        │   │  ← 13pt semibold + SF Symbol circle
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌────────────── TIMER DISPLAY ──────────┐  │
│  │                                        │  │
│  │           23:45                        │  │  ← 32pt light monospacedDigit
│  │      ═══════════●━━━━━━━              │  │  ← Linear progress bar (accent color)
│  │                                        │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  ┌─ PRESETS ─────────────────────────────┐  │
│  │  ╭──────╮ ╭──────╮ ╭──────╮ ╭──────╮ │  │
│  │  │ 20m  │ │ 25m  │ │ 40m  │ │ 52m  │ │  │  ← Capsule buttons, 6pt corner
│  │  ╰──────╯ ╰──────╯ ╰──────╯ ╰──────╯ │  │    Selected = accent fill + white text
│  │           ╭──────────────╮            │  │    Unselected = surfaceHover + primary text
│  │           │  Custom: 30m │            │  │
│  │           ╰──────────────╯            │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  ┌─ CONTROLS ────────────────────────────┐  │
│  │  ╭──────────────────────────────────╮ │  │
│  │  │         ▶ Start Timer            │ │  │  ← Full-width accent button, 10pt corners
│  │  ╰──────────────────────────────────╯ │  │    States: Start / ⏸ Pause / ▶ Resume
│  │                                        │  │
│  │  ╭─────────╮     ╭─────────╮          │  │
│  │  │  ⏹ Stop │     │  ⟳ Reset│          │  │  ← Secondary buttons (text only)
│  │  ╰─────────╯     ╰─────────╯          │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  │  ← Divider (tertiaryLabel @ 20%)
│                                              │
│  ╭──╮ Settings          ╭──╮ Quit   ⌘Q     │  ← SF Symbols: gear + xmark
│  ╰──╯                   ╰──╯               │
│                                              │
└──────────────────────────────────────────────┘
```

### 9.8 Break Window Layout

```
┌──────────────── 420 × 420pt ─────────────────┐
│  ╭ .hudWindow material + cornerRadius 20pt ╮  │
│  │                                          │  │
│  │   ┌─ PROGRESS BAR (top) ──────────────┐ │  │  ← 3pt tall, accent color, full width
│  │   │  ═══════════════●━━━━━━━━━━━━━━━ │ │  │    Shows total break progress
│  │   └───────────────────────────────────┘ │  │
│  │                                          │  │
│  │   Cyclic Sighing                        │  │  ← 14pt medium, textSecondary
│  │                                          │  │
│  │         ┌─────────────────┐              │  │
│  │         │                 │              │  │
│  │         │   ◉◉◉ CIRCLE   │              │  │  ← 180pt diameter, layered:
│  │         │   (3 layers:    │              │  │    Fill + ring + glow
│  │         │    fill/ring/   │              │  │    Scales with spring animation
│  │         │    glow)        │              │  │
│  │         │                 │              │  │
│  │         └─────────────────┘              │  │
│  │                                          │  │
│  │           Inhale                        │  │  ← 22pt semibold, textPrimary
│  │                                          │  │    .contentTransition(.interpolate)
│  │           4                             │  │  ← 48pt light monospacedDigit
│  │                                          │  │    Per-phase countdown
│  │   Cycle 2 of 5         0:37 remaining   │  │  ← 14pt medium, textTertiary
│  │                                          │  │
│  │              ╭──────────╮                │  │
│  │              │ Dismiss  │                │  │  ← Ghost button (textSecondary)
│  │              ╰──────────╯                │  │    .keyboardShortcut(.cancelAction)
│  │                                          │  │
│  ╰──────────────────────────────────────────╯  │
└────────────────────────────────────────────────┘
```

### 9.9 Component Visual Specs

**PulsingCircleView (updated from Section 2.6):**
```swift
struct PulsingCircleView: View {
    var scale: CGFloat              // 0.3–1.0
    var phaseDuration: Double       // Animation duration
    var color: Color = AppColors.accent

    var body: some View {
        ZStack {
            // Layer 3: Glow (outermost)
            Circle()
                .fill(color.opacity(0.08))
                .blur(radius: 20)
                .scaleEffect(scale)
                .animation(breatheAnimation.delay(0.1), value: scale)

            // Layer 2: Ring
            Circle()
                .stroke(color.opacity(0.25), lineWidth: 2)
                .scaleEffect(scale)
                .animation(breatheAnimation.delay(0.05), value: scale)

            // Layer 1: Fill (innermost)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.7), color.opacity(0.3)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 90
                    )
                )
                .scaleEffect(scale)
                .animation(breatheAnimation, value: scale)
        }
        .frame(width: 180, height: 180)
    }

    private var breatheAnimation: Animation {
        .timingCurve(0.4, 0.0, 0.2, 1.0, duration: phaseDuration)
    }
}
```

**CircularCountdownView (updated):**
```swift
struct CircularCountdownView: View {
    var totalSeconds: Double
    var remainingSeconds: Double
    var lineWidth: CGFloat = 4
    var size: CGFloat = 120

    private var progress: Double { remainingSeconds / totalSeconds }

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(AppColors.textTertiary.opacity(0.15), lineWidth: lineWidth)

            // Progress
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AppColors.accent,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: remainingSeconds)

            // Center text
            Text(String(format: "%.0f", remainingSeconds))
                .font(AppTypography.breakCountdown)
                .foregroundStyle(AppColors.textPrimary)
                .contentTransition(.numericText())
        }
        .frame(width: size, height: size)
    }
}
```

### 9.10 Settings Window Visual Spec

```
┌─────────── Settings (480 × 360pt) ───────────┐
│  ┌─ TabView ─────────────────────────────┐    │
│  │  [  General  ] [  Breaks  ]           │    │  ← Standard macOS TabView
│  └───────────────────────────────────────┘    │
│                                               │
│  ┌─ Form ────────────────────────────────┐   │
│  │                                        │   │
│  │  Work Interval                        │   │
│  │  ╭──────╮ ╭──────╮ ╭──────╮ ╭──────╮ │   │
│  │  │ 20m  │ │ 25m  │ │ 40m  │ │ 52m  │ │   │  ← Picker with segmented style
│  │  ╰──────╯ ╰──────╯ ╰──────╯ ╰──────╯ │   │
│  │                                        │   │
│  │  Custom Duration   ╭─── 30 ──╮        │   │  ← Stepper (range: 5–120, step: 5)
│  │                     ╰─────────╯        │   │
│  │                                        │   │
│  │  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─   │   │
│  │                                        │   │
│  │  Sound             ╭──── ON ────╮      │   │  ← Toggle
│  │                     ╰───────────╯      │   │
│  │  Launch at Login    ╭──── OFF ───╮     │   │  ← Toggle
│  │                     ╰───────────╯      │   │
│  │                                        │   │
│  │  Global Shortcut    ⌥⌘B              │   │  ← Display only (v1)
│  │                                        │   │
│  └────────────────────────────────────────┘   │
│                                               │
│        Ikki v1.0 • Made with ♡               │  ← 11pt, textTertiary
└───────────────────────────────────────────────┘
```

### 9.11 Menu Bar Icon States

```
IDLE:     "Ikki"           (text label, system font)
RUNNING:  "23m"            (remaining minutes, monospacedDigit)
          "1:05"           (under 2 minutes: show mm:ss)
PAUSED:   "⏸ 23m"         (pause symbol prefix)
FIRED:    "☀"              (SF Symbol sun.max — attention-grabbing)
ON BREAK: "🫁"             (SF Symbol lungs — breathing indicator)

Implementation: MenuBarExtra(viewModel.menuBarTitle, systemImage: viewModel.menuBarIcon)
  where menuBarIcon switches between "circle.fill", "pause.circle", "sun.max.fill", "lungs.fill"
```

### 9.12 Accessibility Requirements

| Requirement | Implementation |
|---|---|
| Reduced motion | `@Environment(\.accessibilityReduceMotion)` — replace spring with `.none`, replace breathing scale with opacity fade |
| VoiceOver labels | Every control gets `.accessibilityLabel()` and `.accessibilityHint()` |
| Contrast ratio | All text meets WCAG AA (4.5:1) — enforced by using semantic `NSColor` labels |
| Keyboard navigation | Break window: `Esc` = dismiss, `Space` = pause. Popover: full tab navigation |
| Dynamic Type | Not applicable on macOS (system font sizes are fixed), but respect user text size preferences via `NSFont.systemFontSize` |
