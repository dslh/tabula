import Foundation

/// Represents a group of terminal tabs
class TabGroup: Identifiable, ObservableObject, Equatable {
    let id: UUID
    @Published var name: String
    @Published var tabs: [TerminalTab]
    @Published var isExpanded: Bool
    @Published var selectedTabId: UUID?
    @Published var defaultWorkingDirectory: String?

    init(
        id: UUID = UUID(),
        name: String = "Group",
        tabs: [TerminalTab] = [],
        isExpanded: Bool = true,
        defaultWorkingDirectory: String? = nil
    ) {
        self.id = id
        self.name = name
        self.tabs = tabs
        self.isExpanded = isExpanded
        self.selectedTabId = tabs.first?.id
        self.defaultWorkingDirectory = defaultWorkingDirectory
    }

    var selectedTab: TerminalTab? {
        tabs.first { $0.id == selectedTabId }
    }

    func addTab(_ tab: TerminalTab) {
        print("📝 [TabGroup] Adding tab \(tab.id) to group '\(name)'. Current tab count: \(tabs.count)")
        tabs.append(tab)
        if tabs.count == 1 {
            selectedTabId = tab.id
            print("📝 [TabGroup] First tab in group, auto-selecting")
        }
        print("📝 [TabGroup] Tab added. New tab count: \(tabs.count)")
    }

    func removeTab(_ tab: TerminalTab) {
        tabs.removeAll { $0.id == tab.id }
        if selectedTabId == tab.id {
            selectedTabId = tabs.first?.id
        }
    }

    func selectNextTab() {
        guard let currentId = selectedTabId,
              let currentIndex = tabs.firstIndex(where: { $0.id == currentId })
        else { return }

        let nextIndex = (currentIndex + 1) % tabs.count
        selectedTabId = tabs[nextIndex].id
    }

    func selectPreviousTab() {
        guard let currentId = selectedTabId,
              let currentIndex = tabs.firstIndex(where: { $0.id == currentId })
        else { return }

        let previousIndex = (currentIndex - 1 + tabs.count) % tabs.count
        selectedTabId = tabs[previousIndex].id
    }

    func moveTab(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex >= 0, sourceIndex < tabs.count,
              destinationIndex >= 0, destinationIndex < tabs.count,
              sourceIndex != destinationIndex
        else { return }

        let tab = tabs.remove(at: sourceIndex)
        tabs.insert(tab, at: destinationIndex)
    }

    // MARK: - Equatable

    static func == (lhs: TabGroup, rhs: TabGroup) -> Bool {
        lhs.id == rhs.id
    }
}
