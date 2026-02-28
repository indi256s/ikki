import SwiftUI

@main
struct IkkiApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var menuBarVM = MenuBarViewModel()
    @State private var settingsVM = SettingsViewModel()

    @Environment(\.openWindow) private var openWindow

    init() {
        // Need to pass the shared instance or connect manually
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(viewModel: menuBarVM) {
                // Open Settings
                openWindow(id: "settings")
                NSApp.activate(ignoringOtherApps: true)
            } onQuit: {
                NSApp.terminate(nil)
            }
        } label: {
            HStack {
                Image(systemName: menuBarVM.menuBarIcon)
                if !menuBarVM.menuBarTitle.isEmpty {
                    Text(menuBarVM.menuBarTitle)
                }
            }
        }
        .menuBarExtraStyle(.window)

        Window("Settings", id: "settings") {
            SettingsView(viewModel: settingsVM)
                .onAppear {
                    // Window settings (level, etc.) can be set if needed
                }
        }
        .windowResizability(.contentSize)
    }
}
