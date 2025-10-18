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
        }
        .commands {
            TerminalCommands()
        }

        Settings {
            PreferencesView()
                .environmentObject(appState)
        }
    }
}

/// App delegate to handle lifecycle events
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillTerminate(_ notification: Notification) {
        // Save state on quit
        // Note: We need a reference to AppState here
        // For now, this is a placeholder
        print("App will terminate")
    }
}
