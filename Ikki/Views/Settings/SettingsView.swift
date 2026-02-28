import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        TabView {
            // General Tab
            Form {
                Section("Work Timer") {
                    Picker("Default Interval", selection: $viewModel.workIntervalMinutes) {
                        Text("20 minutes").tag(20)
                        Text("25 minutes").tag(25)
                        Text("40 minutes").tag(40)
                        Text("52 minutes").tag(52)
                    }
                    .accessibilityHint("Select a predefined timer duration.")
                    
                    Stepper("Custom Interval: \(viewModel.customIntervalMinutes)m", value: $viewModel.customIntervalMinutes, in: 1...120)
                        .accessibilityHint("Manually adjust the work interval in minutes.")
                }
                
                Section("Sounds & System") {
                    Toggle("Sound Effects", isOn: $viewModel.soundEnabled)
                        .accessibilityHint("Play sounds at the start and end of breaks.")
                    Toggle("Launch at Login", isOn: $viewModel.launchAtLogin)
                        .accessibilityHint("Automatically start Ikki when you log in to macOS.")
                }
            }
            .tabItem {
                Label("General", systemImage: "gearshape")
            }
            .padding(AppSpacing.lg)

            // Breaks Tab
            Form {
                Section("Enabled Breaks") {
                    Toggle("Breathing Exercises", isOn: $viewModel.breathingEnabled)
                        .accessibilityHint("Include breathing exercises in your break rotation.")
                    Toggle("Eye Rest (20-20-20)", isOn: $viewModel.eyeBreakEnabled)
                        .accessibilityHint("Include the 20-20-20 eye rest rule in your break rotation.")
                    Toggle("Blink Reset", isOn: $viewModel.blinkResetEnabled)
                        .accessibilityHint("Include blink reset exercises in your break rotation.")
                    Toggle("Focus Shift", isOn: $viewModel.focusShiftEnabled)
                        .accessibilityHint("Include focus shifting exercises in your break rotation.")
                }
                
                Section("Breathing Defaults") {
                    Picker("Technique", selection: $viewModel.defaultBreathingTechnique) {
                        ForEach(BreathingTechnique.allCases) { technique in
                            Text(technique.displayName).tag(technique.rawValue)
                        }
                    }
                    .accessibilityHint("Choose the default breathing technique for guided breaks.")
                }
            }
            .tabItem {
                Label("Breaks", systemImage: "heart")
            }
            .padding(AppSpacing.lg)
        }
        .frame(width: 400, height: 350)
    }
}
