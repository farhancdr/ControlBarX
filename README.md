# ControlBarX

A macOS menu bar utility that puts system monitoring and keyboard control tools at your fingertips. Click the menu bar icon to access all features in a clean popover panel.

## Features

### Keyboard Blocker
- Toggle switch to block all keyboard input system-wide
- **ESC key passthrough** — configurable toggle (on by default) to prevent lockout
- **Auto-disable timer** — block keyboard for 1, 5, 15, or 30 minutes with countdown and progress bar
- Useful for cleaning your keyboard, preventing accidental input, or keeping cats off your keys

### Network Speed Monitor
- Real-time upload and download speed
- Updates every second
- Formatted display (B/s, KB/s, MB/s, GB/s)

### System Monitor
- **CPU usage** — percentage with color-coded progress bar (green/orange/red)
- **RAM usage** — used/total with color-coded progress bar
- Updates every 2 seconds

### General
- Lives in the menu bar — no dock icon
- Each feature section is collapsible with status indicators
- Launch at Login option
- Monitors only consume resources when enabled

## Requirements

- macOS 15.7+
- Accessibility permission (for keyboard blocking feature)

## Installation

### Manual Install

1. Download `ControlBarX.dmg` from [Releases](../../releases/latest)
2. Open the DMG and drag **ControlBarX** to **Applications**
3. **Important:** Remove the macOS quarantine flag before launching:
   ```bash
   xattr -cr /Applications/ControlBarX.app
   ```
   This is required because the app is ad-hoc signed, not notarized with Apple. You only need to do this once.
4. Launch the app
5. Grant Accessibility permission when prompted:
   - Go to **System Settings > Privacy & Security > Accessibility**
   - Toggle **ControlBarX** on
6. Click the bolt icon in the menu bar to open the panel

## Building from Source

1. Clone the repo
2. Open `ControlBarX.xcodeproj` in Xcode
3. Build and run (Cmd+R)

## License

MIT
