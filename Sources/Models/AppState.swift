import Foundation
import SwiftUI

/// Global application state managing all tab groups
class AppState: ObservableObject {
    @Published var groups: [TabGroup]
    @Published var selectedGroupId: UUID?
    @Published var preferences: Preferences
    @Published var groupToShowSettings: TabGroup?

    init() {
        // Start with one group containing one tab
        let firstTab = TerminalTab(title: "Terminal", isActive: true)
        let firstGroup = TabGroup(name: "Group 1", tabs: [firstTab], isExpanded: true)

        self.groups = [firstGroup]
        self.selectedGroupId = firstGroup.id
        self.preferences = Preferences()

        // Try to restore saved state
        restoreState()
    }

    var selectedGroup: TabGroup? {
        groups.first { $0.id == selectedGroupId }
    }

    // MARK: - Group Management

    func createNewGroup() {
        let groupNumber = groups.count + 1
        let newTab = TerminalTab(title: "Terminal", isActive: true)
        let newGroup = TabGroup(name: "Group \(groupNumber)", tabs: [newTab], isExpanded: true)

        // Collapse all other groups
        for group in groups {
            group.isExpanded = false
        }

        groups.append(newGroup)
        selectedGroupId = newGroup.id

        // Show settings dialog for the new group
        groupToShowSettings = newGroup

        saveState()
    }

    func removeGroup(_ group: TabGroup) {
        groups.removeAll { $0.id == group.id }
        if selectedGroupId == group.id {
            selectedGroupId = groups.first?.id
        }
        saveState()
    }

    func selectGroup(_ groupId: UUID) {
        // Collapse all groups
        for group in groups {
            group.isExpanded = false
        }

        // Expand and select the target group
        if let targetGroup = groups.first(where: { $0.id == groupId }) {
            targetGroup.isExpanded = true
            selectedGroupId = groupId
        }
    }

    func selectNextGroup() {
        guard let currentId = selectedGroupId,
              let currentIndex = groups.firstIndex(where: { $0.id == currentId })
        else { return }

        let nextIndex = (currentIndex + 1) % groups.count
        selectGroup(groups[nextIndex].id)
    }

    func selectPreviousGroup() {
        guard let currentId = selectedGroupId,
              let currentIndex = groups.firstIndex(where: { $0.id == currentId })
        else { return }

        let previousIndex = (currentIndex - 1 + groups.count) % groups.count
        selectGroup(groups[previousIndex].id)
    }

    // MARK: - Tab Management

    func createNewTab(in group: TabGroup, workingDirectory: String? = nil) {
        let workingDir = workingDirectory ?? FileManager.default.homeDirectoryForCurrentUser.path
        let newTab = TerminalTab(title: "Terminal", workingDirectory: workingDir, isActive: true)
        print("📝 [AppState] Creating new tab with ID: \(newTab.id)")
        group.addTab(newTab)
        group.selectedTabId = newTab.id
        print("📝 [AppState] Tab added to group '\(group.name)', selected tab ID: \(group.selectedTabId?.uuidString ?? "nil")")

        // Manually trigger AppState's objectWillChange to force ContentView to re-render
        objectWillChange.send()
        print("🔔 [AppState] Triggered objectWillChange")

        saveState()
    }

    func createNewTabInSelectedGroup() {
        guard let group = selectedGroup else {
            print("⚠️ [AppState] No selected group!")
            return
        }
        print("📝 [AppState] Creating new tab in group '\(group.name)'")

        // Use group's default working directory, or fall back to home
        let workingDir = group.defaultWorkingDirectory ?? FileManager.default.homeDirectoryForCurrentUser.path
        let newTab = TerminalTab(title: "Terminal", workingDirectory: workingDir, isActive: true)
        print("📝 [AppState] Creating new tab with ID: \(newTab.id), using directory: \(workingDir)")
        group.addTab(newTab)
        group.selectedTabId = newTab.id
        print("📝 [AppState] Tab added to group '\(group.name)', selected tab ID: \(group.selectedTabId?.uuidString ?? "nil")")

        objectWillChange.send()
        print("🔔 [AppState] Triggered objectWillChange")

        saveState()
    }

    func closeCurrentTab() {
        guard let group = selectedGroup, let currentTab = group.selectedTab else {
            print("⚠️ [AppState] No tab to close")
            return
        }

        print("🗑️ [AppState] Closing tab \(currentTab.id) in group '\(group.name)'")

        // Don't close the last tab in the last group
        if groups.count == 1 && group.tabs.count == 1 {
            print("⚠️ [AppState] Cannot close the last tab")
            return
        }

        // If this is the last tab in the group, remove the group
        if group.tabs.count == 1 {
            print("🗑️ [AppState] Last tab in group, removing group '\(group.name)'")
            removeGroup(group)
        } else {
            // Remove the tab from the group
            group.removeTab(currentTab)
            objectWillChange.send()
            print("🔔 [AppState] Triggered objectWillChange after removing tab")
        }

        saveState()
    }

    func selectNextTab() {
        guard let group = selectedGroup else { return }
        print("⏭️ [AppState] Selecting next tab in group '\(group.name)'")
        group.selectNextTab()
        objectWillChange.send()
        print("🔔 [AppState] Triggered objectWillChange for tab selection")
    }

    func selectPreviousTab() {
        guard let group = selectedGroup else { return }
        print("⏮️ [AppState] Selecting previous tab in group '\(group.name)'")
        group.selectPreviousTab()
        objectWillChange.send()
        print("🔔 [AppState] Triggered objectWillChange for tab selection")
    }

    func selectTab(_ tabId: UUID, in group: TabGroup) {
        print("🎯 [AppState] Selecting specific tab \(tabId) in group '\(group.name)'")
        group.selectedTabId = tabId
        objectWillChange.send()
        print("🔔 [AppState] Triggered objectWillChange for tab selection")
    }

    // MARK: - Persistence

    func saveState() {
        PersistenceManager.shared.saveState(self)
    }

    private func restoreState() {
        guard let persistedState = PersistenceManager.shared.loadState() else {
            print("No saved state found, using defaults")
            return
        }

        // Restore groups
        self.groups = persistedState.groups.map { $0.toTabGroup() }

        // Restore selected group
        self.selectedGroupId = persistedState.selectedGroupId

        // Restore preferences
        self.preferences = persistedState.preferences.toPreferences()

        print("Restored \(groups.count) group(s)")
    }
}

/// User preferences for the terminal
struct Preferences {
    var fontName: String = "SF Mono"
    var fontSize: CGFloat = 13
    var colorScheme: ColorScheme = .system

    enum ColorScheme: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
    }
}
