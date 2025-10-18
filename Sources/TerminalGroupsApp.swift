import SwiftUI

@main
struct TerminalGroupsApp: App {
    @StateObject private var appState = AppState()

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
