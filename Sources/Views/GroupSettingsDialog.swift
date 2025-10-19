import SwiftUI
import AppKit

struct GroupSettingsDialog: View {
    @ObservedObject var group: TabGroup
    @Binding var isPresented: Bool

    @State private var groupName: String
    @State private var workingDirectory: String
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    init(group: TabGroup, isPresented: Binding<Bool>) {
        self.group = group
        self._isPresented = isPresented
        self._groupName = State(initialValue: group.name)
        self._workingDirectory = State(initialValue: group.defaultWorkingDirectory ?? FileManager.default.homeDirectoryForCurrentUser.path)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Group Settings")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Group Name")
                        .font(.headline)
                    TextField("Group Name", text: $groupName)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Default Working Directory")
                        .font(.headline)
                    HStack {
                        TextField("Directory Path", text: $workingDirectory)
                            .textFieldStyle(.roundedBorder)

                        Button("Browse...") {
                            selectDirectory()
                        }
                        .buttonStyle(.bordered)
                    }

                    Text("New tabs in this group will start in this directory")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 450)

            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            HStack(spacing: 12) {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)

                Button("Save") {
                    saveSettings()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(minWidth: 500)
    }

    private func selectDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.directoryURL = URL(fileURLWithPath: workingDirectory)

        if panel.runModal() == .OK, let url = panel.url {
            workingDirectory = url.path
        }
    }

    private func saveSettings() {
        // Validate group name
        let trimmedName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            showError = true
            errorMessage = "Group name cannot be empty"
            return
        }

        // Validate directory
        let trimmedPath = workingDirectory.trimmingCharacters(in: .whitespacesAndNewlines)
        let expandedPath = (trimmedPath as NSString).expandingTildeInPath

        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: expandedPath, isDirectory: &isDirectory) || !isDirectory.boolValue {
            showError = true
            errorMessage = "Directory does not exist or is not a directory"
            return
        }

        // Save settings
        group.name = trimmedName
        group.defaultWorkingDirectory = expandedPath

        isPresented = false
    }
}
