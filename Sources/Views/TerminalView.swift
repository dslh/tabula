import SwiftUI
import SwiftTerm

struct TerminalView: View {
    @ObservedObject var tab: TerminalTab
    @EnvironmentObject var appState: AppState

    init(tab: TerminalTab) {
        self.tab = tab
        print("🎬 [TerminalView] INIT for tab \(tab.id)")
    }

    var body: some View {
        SwiftTermView(controller: tab.ptyController, tab: tab)
            .onAppear {
                print("👁️ [TerminalView] onAppear for tab \(tab.id)")
                print("👁️ [TerminalView] Controller ID: \(ObjectIdentifier(tab.ptyController))")

                // Only start shell once per tab, even if view is recreated
                if !tab.hasStartedShell {
                    print("🚀 [TerminalView] Starting shell for first time")
                    tab.ptyController.startShell()
                    tab.hasStartedShell = true
                } else {
                    print("♻️ [TerminalView] Reusing existing shell session")
                }

                // Auto-focus the terminal view
                DispatchQueue.main.async {
                    tab.terminalView.window?.makeFirstResponder(tab.terminalView)
                    print("🎯 [TerminalView] Set terminal as first responder")
                }
            }
            .onDisappear {
                print("👋 [TerminalView] onDisappear for tab \(tab.id)")
                // Keep the shell running and hasStartedShell=true
            }
    }
}

/// SwiftUI wrapper for SwiftTerm's TerminalView
struct SwiftTermView: NSViewRepresentable {
    @ObservedObject var controller: PTYController
    @ObservedObject var tab: TerminalTab
    @EnvironmentObject var appState: AppState

    func makeNSView(context: Context) -> LocalProcessTerminalView {
        print("🖼️ [SwiftTermView] makeNSView - returning tab's persistent terminalView")

        // Return the tab's persistent terminal view (created once via lazy var)
        let terminalView = tab.terminalView

        // Apply current preferences
        tab.applyPreferences(appState.preferences)

        // Start thumbnail generation after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            context.coordinator.startThumbnailGeneration(for: terminalView)
        }

        return terminalView
    }

    func updateNSView(_ nsView: LocalProcessTerminalView, context: Context) {
        print("🔄 [SwiftTermView] updateNSView called for tab \(tab.id)")
        // Apply preferences whenever the view updates (e.g., when preferences change)
        tab.applyPreferences(appState.preferences)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(tab: tab)
    }

    class Coordinator {
        let tab: TerminalTab
        var thumbnailTimer: Timer?

        init(tab: TerminalTab) {
            self.tab = tab
        }

        func startThumbnailGeneration(for view: NSView) {
            thumbnailTimer?.invalidate()
            thumbnailTimer = ThumbnailGenerator.shared.scheduleThumbnailUpdates(for: view, interval: 3.0) { [weak self] thumbnail in
                self?.tab.thumbnail = thumbnail
            }
        }

        deinit {
            thumbnailTimer?.invalidate()
        }
    }
}
