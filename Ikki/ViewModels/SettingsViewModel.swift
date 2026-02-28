import Foundation
import Observation

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
        // Register defaults in case keys don't exist
        d.register(defaults: [
            UserDefaultsKeys.workIntervalMinutes: 25,
            UserDefaultsKeys.customIntervalMinutes: 30,
            UserDefaultsKeys.breathingEnabled: true,
            UserDefaultsKeys.eyeBreakEnabled: true,
            UserDefaultsKeys.blinkResetEnabled: true,
            UserDefaultsKeys.focusShiftEnabled: true,
            UserDefaultsKeys.defaultBreathingTechnique: BreathingTechnique.cyclicSighing.rawValue,
            UserDefaultsKeys.soundEnabled: true,
            UserDefaultsKeys.launchAtLogin: false
        ])
        
        workIntervalMinutes = d.integer(forKey: UserDefaultsKeys.workIntervalMinutes)
        customIntervalMinutes = d.integer(forKey: UserDefaultsKeys.customIntervalMinutes)
        breathingEnabled = d.bool(forKey: UserDefaultsKeys.breathingEnabled)
        eyeBreakEnabled = d.bool(forKey: UserDefaultsKeys.eyeBreakEnabled)
        blinkResetEnabled = d.bool(forKey: UserDefaultsKeys.blinkResetEnabled)
        focusShiftEnabled = d.bool(forKey: UserDefaultsKeys.focusShiftEnabled)
        defaultBreathingTechnique = d.string(forKey: UserDefaultsKeys.defaultBreathingTechnique) ?? BreathingTechnique.cyclicSighing.rawValue
        soundEnabled = d.bool(forKey: UserDefaultsKeys.soundEnabled)
        launchAtLogin = d.bool(forKey: UserDefaultsKeys.launchAtLogin)
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try LaunchAtLoginService.shared.enable()
            } else {
                try LaunchAtLoginService.shared.disable()
            }
        } catch {
            print("Failed to set launch at login: \(error.localizedDescription)")
        }
    }
}
