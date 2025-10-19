# Tabula

A native macOS terminal emulator with advanced tab group management, built with Swift and SwiftUI.

*"Tabula" - from "tabula rasa" (clean slate) - fresh terminal sessions organized by tabs.*

## Features

### 🗂️ Tab Groups
- **Organize terminals by project** - Create multiple groups for different tasks or projects
- **Collapsible sidebar** - Only the active group is expanded, keeping your workspace clean
- **Visual thumbnails** - See a preview of each terminal session in the sidebar
- **Auto-save/restore** - Your workspace is automatically saved and restored between sessions

### ⌨️ Keyboard-Driven Workflow
- `⌘N` - Create new tab group
- `⌘T` - Create new tab in current group
- `⌃Tab` / `⌃⇧Tab` - Cycle through tabs in current group
- `⌃⌥Tab` / `⌃⌥⇧Tab` - Cycle through groups

### 🎨 Customization
- Font selection and sizing
- Color scheme (Light, Dark, System)
- Full VT100/xterm terminal emulation via SwiftTerm

## Building

```bash
# Clone the repository
git clone https://github.com/dslh/tabula.git
cd tabula

# Build the project
swift build

# Run the application
swift run
```

## Opening in Xcode

To work with this project in Xcode:

```bash
# Generate Xcode project
swift package generate-xcodeproj

# Or open Package.swift directly (Xcode 11+)
open Package.swift
```

## Architecture

### Models
- **AppState** - Global application state managing all groups
- **TabGroup** - Collection of terminal tabs with shared context
- **TerminalTab** - Individual terminal session

### Views
- **SidebarView** - Collapsible group list with thumbnails
- **TerminalView** - SwiftTerm integration for terminal emulation
- **PreferencesView** - Application settings

### Services
- **PTYController** - PTY management and shell process lifecycle
- **PersistenceManager** - Save/restore app state to disk
- **ThumbnailGenerator** - Generate visual previews of terminal sessions

## Use Case

Perfect for developers who work on multiple projects simultaneously:

- **Web Development**: Group 1 might have tabs for server logs, dev tools, editor, and database console
- **Backend Services**: Group 2 for microservices with a tab per service
- **DevOps**: Group 3 for monitoring, deployment scripts, and SSH sessions
- **Personal Projects**: Group 4 for side projects

No more juggling multiple terminal windows or losing track of which tab belongs to which project!

## Persistence

Session data is automatically saved to:
```
~/Library/Application Support/Tabula/state.json
```

## Requirements

- macOS 14.0+ (Sonoma)
- Xcode 15.0+ (for development)
- Swift 5.9+

## Dependencies

- [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm) - Terminal emulation engine

## License

MIT License - see LICENSE file for details.

Built with [Claude Code](https://claude.com/claude-code).

## Roadmap

Future enhancements could include:
- [ ] Rename individual tabs
- [ ] Custom color coding for groups/tabs
- [ ] Search across all terminal sessions
- [ ] Split panes within tabs
- [ ] tmux integration
- [ ] SSH connection profiles
- [ ] Export/import workspace configurations
- [ ] Tab duplication (spawn new tab in same directory)
- [ ] Hotkey to show/hide app (Quake mode)
