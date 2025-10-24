import Foundation
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
}
