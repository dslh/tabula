import SwiftUI

/// Custom keyboard commands for terminal operations
struct TerminalCommands: Commands {
    @FocusedValue(\.appState) var appState: AppState?

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Group") {
                appState?.createNewGroup()
            }
            .keyboardShortcut("n", modifiers: [.command])

            Button("New Tab") {
                appState?.createNewTabInSelectedGroup()
            }
            .keyboardShortcut("t", modifiers: [.command])

            Divider()

            Button("Close Tab") {
                appState?.closeCurrentTab()
            }
            .keyboardShortcut("w", modifiers: [.command])
        }

        CommandMenu("Tab") {
            Button("Next Tab") {
                appState?.selectNextTab()
            }
            .keyboardShortcut(.tab, modifiers: [.control])

            Button("Previous Tab") {
                appState?.selectPreviousTab()
            }
            .keyboardShortcut(.tab, modifiers: [.control, .shift])

            Divider()

            Button("Next Group") {
                appState?.selectNextGroup()
            }
            .keyboardShortcut(.tab, modifiers: [.control, .option])

            Button("Previous Group") {
                appState?.selectPreviousGroup()
            }
            .keyboardShortcut(.tab, modifiers: [.control, .option, .shift])
        }

        CommandGroup(after: .sidebar) {
            Button("Toggle Sidebar") {
                appState?.toggleSidebar()
            }
            .keyboardShortcut("b", modifiers: [.command])
        }

        CommandMenu("View") {
            Button("Increase Font Size") {
                appState?.increaseFontSize()
            }
            .keyboardShortcut("=", modifiers: [.command])

            Button("Decrease Font Size") {
                appState?.decreaseFontSize()
            }
            .keyboardShortcut("-", modifiers: [.command])
        }
    }
}

// MARK: - FocusedValues

extension FocusedValues {
    struct AppStateKey: FocusedValueKey {
        typealias Value = AppState
    }

    var appState: AppState? {
        get { self[AppStateKey.self] }
        set { self[AppStateKey.self] = newValue }
    }
}
