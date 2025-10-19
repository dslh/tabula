# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Tabula is a native macOS terminal emulator with advanced tab group management. The core feature is organizing terminal sessions into collapsible groups in a sidebar, allowing developers to manage multiple projects simultaneously without juggling windows.

## Building and Running

```bash
# Build the project
swift build

# Run the application
swift run

# Open in Xcode
open Package.swift
```

## Key Architecture Patterns

### Nested ObservableObject Pattern

The app uses nested `ObservableObject`s (AppState → TabGroup → TerminalTab), which has an important caveat: **SwiftUI doesn't automatically propagate change notifications from nested objects up to parent observers**.

**Critical pattern to maintain:**
- Any method that modifies nested object state must call `objectWillChange.send()` on AppState
- Example: When changing `TabGroup.selectedTabId`, call this through an AppState wrapper method that triggers the notification
- Without this, ContentView won't re-render when tab selection changes

See implementations in `AppState.swift`:
- `selectTab()`, `selectNextTab()`, `createNewTab()` all call `objectWillChange.send()`

### Terminal Session Persistence

Each `TerminalTab` owns its terminal view and PTY controller as persistent properties:
- `lazy var terminalView: LocalProcessTerminalView` - Created once, reused when switching tabs
- `let ptyController: PTYController` - Tied to tab lifecycle, not view lifecycle
- `var hasStartedShell: Bool` - Prevents restarting shell when view is recreated

**Why this matters:** SwiftUI's `.id()` modifier forces view recreation when switching tabs, but we need the underlying shell session to persist. The lazy terminal view and PTY controller stay alive with the tab object, not the SwiftUI view.

### PTY Controller Bi-directional References

`PTYController` has a `weak var tab: TerminalTab?` reference to update the tab's properties from shell callbacks:
- `setTerminalTitle()` → updates `tab.title` (shown in sidebar)
- `hostCurrentDirectoryUpdate()` → updates `tab.workingDirectory` (shown in sidebar)

This creates a cycle: Tab → PTYController → Tab, but the weak reference prevents retain cycles.

## State Management

**Persistence location:** `~/Library/Application Support/Tabula/state.json`

State is automatically saved on:
- Tab creation/deletion
- Group creation/deletion
- Tab selection changes

Restored on app launch via `AppState.restoreState()`.

## Keyboard Shortcuts

All shortcuts must route through AppState wrapper methods to trigger view updates:
- `⌘N` → `createNewGroup()`
- `⌘T` → `createNewTabInSelectedGroup()` (inherits working directory from current tab)
- `⌘W` → `closeCurrentTab()` (won't close last tab in last group)
- `⌃Tab` / `⌃⇧Tab` → `selectNextTab()` / `selectPreviousTab()`
- `⌃⌥Tab` → `selectNextGroup()` / `selectPreviousGroup()`

Defined in `TerminalCommands.swift` using `@FocusedValue(\.appState)`.

## Common Pitfalls

1. **Don't modify TabGroup or TerminalTab state directly from views** - Always go through AppState methods
2. **SwiftTermView must return the tab's persistent terminalView** - Don't create new instances in `makeNSView()`
3. **Auto-focus requires dispatching to main queue** - `tab.terminalView.window?.makeFirstResponder()` must be async
4. **Shell startup uses tab's working directory** - PTYController checks `tab?.workingDirectory` before falling back to home

## File Organization

```
Sources/
├── TabulaApp.swift           # App entry point, window configuration
├── Models/
│   ├── AppState.swift        # Global state, all state mutations go here
│   ├── TabGroup.swift        # Collection of tabs with selection state
│   └── TerminalTab.swift     # Tab with persistent PTY/terminal view
├── Views/
│   ├── ContentView.swift     # Main split view layout
│   ├── SidebarView.swift     # Collapsible groups with thumbnails
│   ├── TerminalView.swift    # SwiftTerm wrapper, auto-focus logic
│   ├── TerminalCommands.swift # Keyboard shortcuts
│   └── PreferencesView.swift
└── Services/
    ├── PTYController.swift        # PTY/shell lifecycle, callbacks
    ├── PersistenceManager.swift   # JSON state save/restore
    └── ThumbnailGenerator.swift   # Terminal view thumbnails
```
