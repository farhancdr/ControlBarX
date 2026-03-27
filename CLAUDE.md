# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ControlBarX is a macOS menu bar utility app (no dock icon) that provides system monitoring and keyboard control tools in a single popover panel. Requires macOS 15.7+ and Accessibility permission (for keyboard blocking).

## Build Commands

```bash
# Build via Xcode CLI
xcodebuild -scheme ControlBarX -configuration Release -project ControlBarX.xcodeproj -derivedDataPath build build

# Ad-hoc sign (required for running outside Xcode)
codesign --force --deep -s - build/Build/Products/Release/ControlBarX.app

# Create DMG for distribution
hdiutil create -volname "ControlBarX" -srcfolder dmg-staging -ov -format UDZO ControlBarX.dmg
```

Or open `ControlBarX.xcodeproj` in Xcode and build with Cmd+R.

## Architecture

SwiftUI app using the Observation framework (`@Observable`) with a modular feature/view split:

### App Entry
- **ControlBarXApp.swift** — `@main` entry point using `MenuBarExtra` with `.window` style for the popover UI.

### Features (Observable models)
- **Features/KeyboardBlocker.swift** — CGEvent tap that intercepts keyboard events system-wide. Includes auto-disable timer. The event tap callback is a free C-function (`keyboardCallback`) passed via `Unmanaged` pointer.
- **Features/NetworkMonitor.swift** — Polls `getifaddrs()` every 1s to calculate upload/download bytes delta across active interfaces (`en*`, `lo*`).
- **Features/SystemMonitor.swift** — Uses `host_processor_info` for CPU usage and `host_statistics64` for memory stats, polled every 2s.

### Views (SwiftUI)
- **Views/MenuContentView.swift** — Main popover layout with collapsible sections and footer (Launch at Login, Quit).
- **Views/KeyboardSection.swift** — Keyboard blocker toggle, ESC passthrough, auto-disable timer buttons.
- **Views/NetworkSection.swift** — Upload/download speed display with formatted rates.
- **Views/SystemSection.swift** — CPU and RAM usage with color-coded progress bars.

Each section is collapsible and independently toggleable. Features only consume resources when their monitor is active.
