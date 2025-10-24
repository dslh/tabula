import Foundation
import SwiftUI
import SwiftTerm

/// Represents a single terminal tab within a group
class TerminalTab: Identifiable, ObservableObject {
    let id: UUID
    @Published var title: String
    @Published var workingDirectory: String
    @Published var thumbnail: NSImage?
    @Published var isActive: Bool

    // Terminal state is managed by PTYController - created once and kept alive
    let ptyController: PTYController
    var hasStartedShell = false

    // The actual terminal view - created once and kept alive with the tab
    // Uses CustomLocalProcessTerminalView to prevent zero-frame buffer issues
    lazy var terminalView: CustomLocalProcessTerminalView = {
        let view = CustomLocalProcessTerminalView(frame: .zero)
        view.processDelegate = ptyController
        view.getTerminal().silentLog = true
        ptyController.terminalView = view
        print("🖥️ [TerminalTab] Created CustomLocalProcessTerminalView for tab \(id)")
        return view
    }()

    /// Applies appearance preferences to the terminal view
    func applyPreferences(_ preferences: Preferences) {
        // Apply font
        if let font = NSFont(name: preferences.fontName, size: preferences.fontSize) {
            terminalView.font = font
            print("🎨 [TerminalTab] Applied font: \(preferences.fontName) \(preferences.fontSize)pt")
        } else {
            // Fallback to monospace font if specified font is not available
            terminalView.font = NSFont.monospacedSystemFont(ofSize: preferences.fontSize, weight: .regular)
            print("⚠️ [TerminalTab] Font '\(preferences.fontName)' not found, using monospace system font")
        }

        // Apply color scheme
        switch preferences.colorScheme {
        case .light:
            terminalView.nativeForegroundColor = .black
            terminalView.nativeBackgroundColor = .white
            print("🎨 [TerminalTab] Applied light color scheme")
        case .dark:
            terminalView.nativeForegroundColor = .white
            terminalView.nativeBackgroundColor = .black
            print("🎨 [TerminalTab] Applied dark color scheme")
        case .system:
            // Use system appearance
            if NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
                terminalView.nativeForegroundColor = .white
                terminalView.nativeBackgroundColor = .black
            } else {
                terminalView.nativeForegroundColor = .black
                terminalView.nativeBackgroundColor = .white
            }
            print("🎨 [TerminalTab] Applied system color scheme")
        }
    }

    init(
        id: UUID = UUID(),
        title: String = "Terminal",
        workingDirectory: String = FileManager.default.homeDirectoryForCurrentUser.path,
        isActive: Bool = false
    ) {
        self.id = id
        self.title = title
        self.workingDirectory = workingDirectory
        self.isActive = isActive

        // Create PTYController once when tab is created
        self.ptyController = PTYController()
        self.ptyController.tab = self  // Link controller back to tab
        print("🆕 [TerminalTab] Created tab \(id) with controller \(ObjectIdentifier(ptyController))")
    }
}
