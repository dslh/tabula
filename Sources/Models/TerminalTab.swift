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
    lazy var terminalView: LocalProcessTerminalView = {
        let view = LocalProcessTerminalView(frame: .zero)
        view.processDelegate = ptyController
        view.getTerminal().silentLog = true
        ptyController.terminalView = view
        print("🖥️ [TerminalTab] Created LocalProcessTerminalView for tab \(id)")
        return view
    }()

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
