import Foundation
import SwiftUI

/// Represents a single terminal tab within a group
class TerminalTab: Identifiable, ObservableObject {
    let id: UUID
    @Published var title: String
    @Published var workingDirectory: String
    @Published var thumbnail: NSImage?
    @Published var isActive: Bool

    // Terminal state will be managed by PTYController
    weak var ptyController: PTYController?

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
    }
}
