import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            GeneralPreferences()
                .environmentObject(appState)
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            AppearancePreferences()
                .environmentObject(appState)
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }
        }
        .frame(width: 500, height: 400)
    }
}

struct GeneralPreferences: View {
    var body: some View {
        Form {
            Section("Shell") {
                Text("Default shell: /bin/zsh")
                    .foregroundColor(.secondary)
            }

            Section("Startup") {
                Toggle("Restore previous session", isOn: .constant(true))
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct AppearancePreferences: View {
    @EnvironmentObject var appState: AppState

    // List of common monospace fonts available on macOS
    private let monospaceFonts: [String] = {
        let fontFamilies = NSFontManager.shared.availableFontFamilies
        var monospace: [String] = []

        // Check each font family to see if it's monospace
        for family in fontFamilies {
            if let font = NSFont(name: family, size: 12) {
                // Check if the font is fixed pitch (monospace)
                if font.isFixedPitch {
                    monospace.append(family)
                }
            }
        }

        // Add some common monospace fonts that might not be detected
        let commonMonospace = ["SF Mono", "Menlo", "Monaco", "Courier", "Courier New",
                               "Andale Mono", "DejaVu Sans Mono", "Consolas",
                               "Source Code Pro", "Fira Code", "JetBrains Mono"]

        // Combine and deduplicate
        let combined = Set(monospace + commonMonospace)

        // Filter to only fonts that actually exist
        return combined.filter { fontName in
            NSFont(name: fontName, size: 12) != nil
        }.sorted()
    }()

    var body: some View {
        Form {
            Section("Font") {
                Picker("Font:", selection: $appState.preferences.fontName) {
                    ForEach(monospaceFonts, id: \.self) { fontName in
                        Text(fontName).tag(fontName)
                    }
                }

                Slider(
                    value: Binding(
                        get: { Double(appState.preferences.fontSize) },
                        set: { appState.preferences.fontSize = CGFloat($0) }
                    ),
                    in: 10...24,
                    step: 1
                ) {
                    Text("Size:")
                } minimumValueLabel: {
                    Text("10")
                } maximumValueLabel: {
                    Text("24")
                }

                Text("Size: \(Int(appState.preferences.fontSize))")
                    .foregroundColor(.secondary)
            }

            Section("Theme") {
                Picker("Color Scheme:", selection: $appState.preferences.colorScheme) {
                    ForEach(Preferences.ColorScheme.allCases, id: \.self) { scheme in
                        Text(scheme.rawValue).tag(scheme)
                    }
                }
                .pickerStyle(.radioGroup)
            }
        }
        .formStyle(.grouped)
        .padding()
        .onChange(of: appState.preferences) { _, _ in
            // Save state when preferences change
            appState.saveState()
            // Trigger objectWillChange to update all terminal views
            appState.objectWillChange.send()
        }
    }
}
