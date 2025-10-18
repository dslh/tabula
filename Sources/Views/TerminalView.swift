import SwiftUI
import SwiftTerm

struct TerminalView: View {
    @ObservedObject var tab: TerminalTab
    @EnvironmentObject var appState: AppState
    @StateObject private var controller = PTYController()

    var body: some View {
        SwiftTermView(controller: controller, tab: tab)
            .onAppear {
                tab.ptyController = controller
                controller.startShell()
            }
            .onDisappear {
                // Keep the shell running, just detach
            }
    }
}

/// SwiftUI wrapper for SwiftTerm's TerminalView
struct SwiftTermView: NSViewRepresentable {
    @ObservedObject var controller: PTYController
    @ObservedObject var tab: TerminalTab

    func makeNSView(context: Context) -> LocalProcessTerminalView {
        let terminalView = LocalProcessTerminalView(frame: .zero)
        terminalView.processDelegate = controller
        terminalView.getTerminal().silentLog = true

        controller.terminalView = terminalView

        // Start thumbnail generation after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            context.coordinator.startThumbnailGeneration(for: terminalView)
        }

        return terminalView
    }

    func updateNSView(_ nsView: LocalProcessTerminalView, context: Context) {
        // Update view if needed
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
