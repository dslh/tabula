import Foundation

/// Represents a group of terminal tabs
class TabGroup: Identifiable, ObservableObject {
    let id: UUID
    @Published var name: String
    @Published var tabs: [TerminalTab]
    @Published var isExpanded: Bool
    @Published var selectedTabId: UUID?

    init(
        id: UUID = UUID(),
        name: String = "Group",
        tabs: [TerminalTab] = [],
        isExpanded: Bool = true
    ) {
        self.id = id
        self.name = name
        self.tabs = tabs
        self.isExpanded = isExpanded
        self.selectedTabId = tabs.first?.id
    }

    var selectedTab: TerminalTab? {
        tabs.first { $0.id == selectedTabId }
    }

    func addTab(_ tab: TerminalTab) {
        tabs.append(tab)
        if tabs.count == 1 {
            selectedTabId = tab.id
        }
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
}
