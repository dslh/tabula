import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 350)
        } detail: {
            if let group = appState.selectedGroup,
               let tab = group.selectedTab {
                let _ = print("🖼️ [ContentView] Rendering TerminalView for tab \(tab.id)")
                TerminalView(tab: tab)
                    .id(tab.id)  // Force new view instance for each tab
            } else {
                Text("No terminal selected")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(NSColor.windowBackgroundColor))
            }
        }
        .focusedSceneValue(\.appState, appState)
    }
}
