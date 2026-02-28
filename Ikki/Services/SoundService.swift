import Foundation
import AppKit

final class SoundService {
    static let shared = SoundService()

    func playBreakStart() {
        play(named: "Glass") // System default if custom is missing
    }

    func playBreakEnd() {
        play(named: "Blow") // System default
    }

    private func play(named name: String) {
        // Respect UserDefaults sound-enabled setting (to be implemented in SettingsViewModel)
        let soundEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.soundEnabled)
        guard soundEnabled else { return }

        if let sound = NSSound(named: name) {
            sound.play()
        } else {
            NSSound.beep()
        }
    }
}
