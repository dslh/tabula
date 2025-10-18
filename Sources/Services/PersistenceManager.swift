import Foundation

/// Manages saving and loading app state to/from disk
class PersistenceManager {
    static let shared = PersistenceManager()

    private let fileURL: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("TerminalGroups", isDirectory: true)

        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)

        return appDir.appendingPathComponent("state.json")
    }()

    private init() {}

    // MARK: - Save/Load

    func saveState(_ appState: AppState) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = PersistedState(from: appState)
            let encoded = try encoder.encode(data)
            try encoded.write(to: fileURL)
            print("State saved to: \(fileURL.path)")
        } catch {
            print("Failed to save state: \(error)")
        }
    }

    func loadState() -> PersistedState? {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let state = try decoder.decode(PersistedState.self, from: data)
            print("State loaded from: \(fileURL.path)")
            return state
        } catch {
            print("Failed to load state: \(error)")
            return nil
        }
    }
}

// MARK: - Codable Models

struct PersistedState: Codable {
    var groups: [PersistedGroup]
    var selectedGroupId: UUID?
    var preferences: PersistedPreferences

    init(from appState: AppState) {
        self.groups = appState.groups.map { PersistedGroup(from: $0) }
        self.selectedGroupId = appState.selectedGroupId
        self.preferences = PersistedPreferences(from: appState.preferences)
    }
}

struct PersistedGroup: Codable {
    var id: UUID
    var name: String
    var tabs: [PersistedTab]
    var isExpanded: Bool
    var selectedTabId: UUID?

    init(from group: TabGroup) {
        self.id = group.id
        self.name = group.name
        self.tabs = group.tabs.map { PersistedTab(from: $0) }
        self.isExpanded = group.isExpanded
        self.selectedTabId = group.selectedTabId
    }

    func toTabGroup() -> TabGroup {
        let group = TabGroup(
            id: id,
            name: name,
            tabs: tabs.map { $0.toTerminalTab() },
            isExpanded: isExpanded
        )
        group.selectedTabId = selectedTabId
        return group
    }
}

struct PersistedTab: Codable {
    var id: UUID
    var title: String
    var workingDirectory: String

    init(from tab: TerminalTab) {
        self.id = tab.id
        self.title = tab.title
        self.workingDirectory = tab.workingDirectory
    }

    func toTerminalTab() -> TerminalTab {
        TerminalTab(
            id: id,
            title: title,
            workingDirectory: workingDirectory
        )
    }
}

struct PersistedPreferences: Codable {
    var fontName: String
    var fontSize: Double
    var colorScheme: String

    init(from preferences: Preferences) {
        self.fontName = preferences.fontName
        self.fontSize = Double(preferences.fontSize)
        self.colorScheme = preferences.colorScheme.rawValue
    }

    func toPreferences() -> Preferences {
        var prefs = Preferences()
        prefs.fontName = fontName
        prefs.fontSize = CGFloat(fontSize)
        prefs.colorScheme = Preferences.ColorScheme(rawValue: colorScheme) ?? .system
        return prefs
    }
}
