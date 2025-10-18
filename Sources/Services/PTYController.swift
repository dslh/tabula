import Foundation
import SwiftTerm

/// Manages the PTY (pseudo-terminal) and shell process lifecycle
class PTYController: NSObject, ObservableObject, LocalProcessTerminalViewDelegate {
    weak var terminalView: LocalProcessTerminalView?
    private var childProcessId: Int32 = 0
    private var shellPath: String {
        // Use user's default shell from environment, fallback to zsh
        ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
    }

    override init() {
        super.init()
    }

    func startShell(in directory: String? = nil) {
        guard let terminalView = terminalView else {
            print("Error: terminalView not set")
            return
        }

        let workingDirectory = directory ?? FileManager.default.homeDirectoryForCurrentUser.path

        // Set environment variables
        var env = ProcessInfo.processInfo.environment
        env["TERM"] = "xterm-256color"
        env["COLORTERM"] = "truecolor"
        env["PWD"] = workingDirectory

        // Convert environment to array of C strings
        let envArray = env.map { "\($0.key)=\($0.value)" }

        // Start the shell as a login shell
        // For a login shell, we use -l flag
        // SwiftTerm will automatically set argv[0] to the shell name
        let args: [String] = []

        terminalView.startProcess(
            executable: shellPath,
            args: args,
            environment: envArray,
            execName: "-" + (shellPath as NSString).lastPathComponent  // Login shell
        )
    }

    // MARK: - LocalProcessTerminalViewDelegate

    func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {
        // Terminal size changed, PTY will be automatically updated by SwiftTerm
    }

    func setTerminalTitle(source: LocalProcessTerminalView, title: String) {
        // Could update the tab title here
        print("Terminal title: \(title)")
    }

    func hostCurrentDirectoryUpdate (source: SwiftTerm.TerminalView, directory: String?) {
        // Could update the working directory in the tab here
        if let dir = directory {
            print("Working directory: \(dir)")
        }
    }

    func processTerminated (source: SwiftTerm.TerminalView, exitCode: Int32?) {
        print("Shell process terminated with exit code: \(exitCode ?? -1)")
        // Could handle shell exit here (restart, close tab, etc.)
    }
}
