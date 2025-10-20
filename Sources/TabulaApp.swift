import SwiftUI

@main
struct TerminalGroupsApp: App {
    @StateObject private var appState = AppState()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .frame(minWidth: 800, minHeight: 600)
                .preferredColorScheme(colorScheme(from: appState.preferences.colorScheme))
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            TerminalCommands()
        }

        Settings {
            PreferencesView()
                .environmentObject(appState)
                .preferredColorScheme(colorScheme(from: appState.preferences.colorScheme))
        }
    }

    /// Converts app preferences color scheme to SwiftUI color scheme
    private func colorScheme(from preference: Preferences.ColorScheme) -> ColorScheme? {
        switch preference {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil  // nil means follow system setting
        }
    }
}

/// App delegate to handle lifecycle events
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Force the app to activate and accept keyboard input
        // This is needed when running as a Swift Package executable
        NSApplication.shared.setActivationPolicy(.regular)
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Save state on quit
        // Note: We need a reference to AppState here
        // For now, this is a placeholder
        print("App will terminate")
    }
}
