import SwiftUI
import SwiftTerm

struct TerminalView: View {
    @ObservedObject var tab: TerminalTab
    @EnvironmentObject var appState: AppState

    init(tab: TerminalTab) {
        self.tab = tab
        print("🎬 [TerminalView] INIT for tab \(tab.id)")
    }

    /// Calculate total font height including line spacing
    private func fontTotalHeight(_ font: NSFont) -> CGFloat {
        let lineHeight = font.ascender - font.descender
        let lineSpacing = font.leading
        return (lineHeight + lineSpacing).rounded(.up)
    }

    var body: some View {
        GeometryReader { geometry in
            let containerHeight = geometry.size.height

            // Get the font that will be used
            let font = NSFont(name: appState.preferences.fontName, size: appState.preferences.fontSize)
                ?? NSFont.monospacedSystemFont(ofSize: appState.preferences.fontSize, weight: .regular)

            let totalFontHeight = fontTotalHeight(font)

            // Constrain height to integer multiples of font height
            // This prevents partial character rows and buffer calculation issues
            let constrainedHeight = containerHeight - containerHeight.truncatingRemainder(
                dividingBy: totalFontHeight
            )

            SwiftTermView(controller: tab.ptyController, tab: tab, preferences: appState.preferences)
                .frame(height: max(0, constrainedHeight))
                .onChange(of: appState.preferences) { oldPreferences, newPreferences in
                    print("🎨 [TerminalView] Preferences changed, applying to tab \(tab.id)")
                    tab.applyPreferences(newPreferences)
                }
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
}

/// SwiftUI wrapper for SwiftTerm's TerminalView
struct SwiftTermView: NSViewRepresentable {
    @ObservedObject var controller: PTYController
    @ObservedObject var tab: TerminalTab
    let preferences: Preferences

    func makeNSView(context: Context) -> CustomLocalProcessTerminalView {
        print("🖼️ [SwiftTermView] makeNSView - returning tab's persistent terminalView")

        // Return the tab's persistent terminal view (created once via lazy var)
        let terminalView = tab.terminalView

        // Apply initial preferences
        tab.applyPreferences(preferences)

        // Start thumbnail generation after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            context.coordinator.startThumbnailGeneration(for: terminalView)
        }

        return terminalView
    }

    func updateNSView(_ nsView: CustomLocalProcessTerminalView, context: Context) {
        print("🔄 [SwiftTermView] updateNSView called for tab \(tab.id)")

        // Soft reset + empty feed forces a visual refresh without clearing buffer
        // This ensures the terminal properly redraws after tab switching
        nsView.getTerminal().softReset()
        nsView.feed(text: "")
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
