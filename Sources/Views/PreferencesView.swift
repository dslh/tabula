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

    var body: some View {
        Form {
            Section("Font") {
                HStack {
                    Text("Font:")
                    Spacer()
                    Text(appState.preferences.fontName)
                        .foregroundColor(.secondary)
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
    }
}
