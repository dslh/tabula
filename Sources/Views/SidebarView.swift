import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let terminalTab = UTType(exportedAs: "com.tabula.terminaltab")
}

// Helper struct to make the tab ID codable for drag and drop
struct DraggedTab: Codable {
    let tabId: String
}

struct SidebarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        List {
            ForEach(appState.groups) { group in
                GroupSection(group: group)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Terminal Groups")
    }
}

struct GroupSection: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var group: TabGroup

    var body: some View {
        Section {
            if group.isExpanded {
                ForEach(group.tabs) { tab in
                    TabRow(tab: tab, group: group)
                }
            }
        } header: {
            GroupHeader(group: group)
        }
    }
}

struct GroupHeader: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var group: TabGroup
    @State private var showSettingsDialog = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: group.isExpanded ? "chevron.down" : "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .frame(width: 12)

            Text(group.name)
                .font(.headline)
                .onTapGesture(count: 2) {
                    showSettingsDialog = true
                }

            Spacer()

            Text("\(group.tabs.count)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                appState.selectGroup(group.id)
            }
        }
        .contextMenu {
            Button("Settings...") {
                showSettingsDialog = true
            }
            Divider()
            Button("Delete Group", role: .destructive) {
                appState.removeGroup(group)
            }
            .disabled(appState.groups.count == 1)
        }
        .sheet(isPresented: $showSettingsDialog) {
            GroupSettingsDialog(group: group, isPresented: $showSettingsDialog)
        }
    }
}

struct TabRow: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var tab: TerminalTab
    @ObservedObject var group: TabGroup
    @State private var isDropTarget = false

    var isSelected: Bool {
        group.selectedTabId == tab.id
    }

    var tabIndex: Int? {
        group.tabs.firstIndex(where: { $0.id == tab.id })
    }

    // Abbreviate home directory with ~
    private func abbreviatedPath(_ path: String) -> String {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
        if path.hasPrefix(homeDir) {
            return path.replacingOccurrences(of: homeDir, with: "~")
        }
        return path
    }

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let thumbnail = tab.thumbnail {
                Image(nsImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 40)
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 60, height: 40)
                    .overlay(
                        Image(systemName: "terminal")
                            .foregroundColor(.secondary)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(tab.title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .lineLimit(1)

                Text(abbreviatedPath(tab.workingDirectory))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.head)
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            ZStack {
                if isSelected {
                    Color.accentColor.opacity(0.15)
                }
                if isDropTarget {
                    Color.accentColor.opacity(0.3)
                }
            }
        )
        .cornerRadius(6)
        .onTapGesture {
            appState.selectTab(tab.id, in: group)
        }
        .contextMenu {
            Button("Close Tab") {
                group.removeTab(tab)
            }
            .disabled(group.tabs.count == 1)
        }
        .onDrag {
            print("🚀 [TabRow] Starting drag for tab '\(tab.title)' with ID \(tab.id)")
            return NSItemProvider(object: tab.id.uuidString as NSString)
        }
        .onDrop(of: [.plainText], delegate: TabDropDelegate(
            tab: tab,
            group: group,
            appState: appState,
            isDropTarget: $isDropTarget
        ))
    }
}

struct TabDropDelegate: DropDelegate {
    let tab: TerminalTab
    let group: TabGroup
    let appState: AppState
    @Binding var isDropTarget: Bool

    func validateDrop(info: DropInfo) -> Bool {
        let hasPlainText = info.hasItemsConforming(to: [.plainText])
        print("🔍 [TabDropDelegate] validateDrop called for tab '\(tab.title)': hasPlainText=\(hasPlainText)")
        print("🔍 [TabDropDelegate] Available types: \(info.itemProviders(for: [.plainText]).first?.registeredTypeIdentifiers ?? [])")
        return hasPlainText
    }

    func dropEntered(info: DropInfo) {
        print("✅ [TabDropDelegate] dropEntered for tab '\(tab.title)'")
        isDropTarget = true
    }

    func dropExited(info: DropInfo) {
        print("❌ [TabDropDelegate] dropExited for tab '\(tab.title)'")
        isDropTarget = false
    }

    func performDrop(info: DropInfo) -> Bool {
        print("🎯 [TabDropDelegate] performDrop called for tab '\(tab.title)'")
        isDropTarget = false

        guard let itemProvider = info.itemProviders(for: [.plainText]).first else {
            print("⚠️ [TabDropDelegate] No item provider found")
            return false
        }

        print("📦 [TabDropDelegate] Item provider found, loading data...")

        itemProvider.loadObject(ofClass: NSString.self) { object, error in
            if let error = error {
                print("❌ [TabDropDelegate] Error loading item: \(error)")
                return
            }

            guard let uuidString = object as? String else {
                print("⚠️ [TabDropDelegate] Could not get string from object: \(String(describing: object))")
                return
            }

            print("📝 [TabDropDelegate] Decoded UUID string: \(uuidString)")

            guard let draggedTabId = UUID(uuidString: uuidString) else {
                print("⚠️ [TabDropDelegate] Invalid UUID string: \(uuidString)")
                return
            }

            guard let sourceIndex = self.group.tabs.firstIndex(where: { $0.id == draggedTabId }) else {
                print("⚠️ [TabDropDelegate] Could not find source tab with ID \(draggedTabId)")
                return
            }

            guard let destinationIndex = self.group.tabs.firstIndex(where: { $0.id == self.tab.id }) else {
                print("⚠️ [TabDropDelegate] Could not find destination tab with ID \(self.tab.id)")
                return
            }

            print("🔄 [TabDropDelegate] Moving tab from index \(sourceIndex) to \(destinationIndex)")

            DispatchQueue.main.async {
                self.appState.reorderTab(in: self.group, from: sourceIndex, to: destinationIndex)
            }
        }

        return true
    }
}
