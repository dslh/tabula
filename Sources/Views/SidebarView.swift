import SwiftUI

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
    @State private var isEditingName = false
    @State private var editedName = ""

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: group.isExpanded ? "chevron.down" : "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .frame(width: 12)

            if isEditingName {
                TextField("Group Name", text: $editedName, onCommit: {
                    if !editedName.isEmpty {
                        group.name = editedName
                    }
                    isEditingName = false
                })
                .textFieldStyle(.plain)
                .font(.headline)
            } else {
                Text(group.name)
                    .font(.headline)
                    .onTapGesture(count: 2) {
                        editedName = group.name
                        isEditingName = true
                    }
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
            Button("Rename") {
                editedName = group.name
                isEditingName = true
            }
            Divider()
            Button("Delete Group", role: .destructive) {
                appState.removeGroup(group)
            }
            .disabled(appState.groups.count == 1)
        }
    }
}

struct TabRow: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var tab: TerminalTab
    @ObservedObject var group: TabGroup

    var isSelected: Bool {
        group.selectedTabId == tab.id
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

                Text(tab.workingDirectory)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
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
    }
}
