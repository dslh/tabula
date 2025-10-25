import Foundation
import AppKit
import SwiftTerm

/// Custom LocalProcessTerminalView with zero-frame protection
/// This extends SwiftTerm's LocalProcessTerminalView to prevent buffer truncation
/// issues during SwiftUI view lifecycle changes
class CustomLocalProcessTerminalView: LocalProcessTerminalView {

    /// Prevents SwiftUI from assigning zero frames during view transitions
    /// Zero frames can cause SwiftTerm to clear or truncate the terminal buffer
    public override func setFrameSize(_ newSize: NSSize) {
        if newSize != .zero {
            super.setFrameSize(newSize)
        } else {
            print("🛡️ [CustomLocalProcessTerminalView] Blocked zero frame assignment in setFrameSize")
        }
    }

    /// Prevents SwiftUI from assigning zero frames during view transitions
    public override var frame: CGRect {
        get {
            super.frame
        }
        set {
            if newValue.size != .zero {
                super.frame = newValue
            } else {
                print("🛡️ [CustomLocalProcessTerminalView] Blocked zero frame assignment in frame setter")
            }
        }
    }

    /// Override copy to properly extract and copy selected terminal text
    /// Uses CodeEdit's SwiftTerm fork which exposes selectedPositions() API
    @objc
    public override func copy(_ sender: Any) {
        let range = selectedPositions()
        let text = terminal.getText(start: range.start, end: range.end)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        print("📋 [CustomLocalProcessTerminalView] Copied \(text.count) characters to clipboard")
    }

    /// Terminates the shell process if it's running
    public func terminateShellProcess() {
        // Use reflection to access the internal process property
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if child.label == "process", let process = child.value as? LocalProcess {
                let shellPid = process.shellPid
                if shellPid > 0 {
                    print("🛑 [CustomLocalProcessTerminalView] Terminating process with PID: \(shellPid)")
                    kill(shellPid, SIGTERM)
                    return
                }
            }
        }
        print("⚠️ [CustomLocalProcessTerminalView] No process found to terminate")
    }
}
