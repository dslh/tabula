import SwiftUI
import SwiftTerm

struct TerminalView: View {
    @ObservedObject var tab: TerminalTab
    @EnvironmentObject var appState: AppState
    @StateObject private var controller = PTYController()

    var body: some View {
        SwiftTermView(controller: controller)
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

    func makeNSView(context: Context) -> LocalProcessTerminalView {
        let terminalView = LocalProcessTerminalView(frame: .zero)
        terminalView.processDelegate = controller
        terminalView.getTerminal().silentLog = true

        controller.terminalView = terminalView
        return terminalView
    }

    func updateNSView(_ nsView: LocalProcessTerminalView, context: Context) {
        // Update view if needed
    }
}
