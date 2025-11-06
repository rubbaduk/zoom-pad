# zoom-pad

A lightweight macOS utility that enables smooth zoom functionality using mousewheel scrolling with keyboard modifiers.

## Features

- **Smooth Zoom Control**: Zoom in and out of any application using trackpad scroll gestures
- **Modifier Key Support**: Uses Command key as the default trigger modifier
- **Configurable Threshold**: Adjustable scroll sensitivity for precise control
- **Scroll Direction**: Optional scroll inversion support
- **System Integration**: Seamlessly integrates with macOS accessibility features

## How It Works

zoom-pad intercepts mousewheel scroll events when the modifier key (Command by default) is held down and converts them into zoom commands (`Cmd++` for zoom in, `Cmd+-` for zoom out). This provides a natural and intuitive way to zoom in any macOS application that supports keyboard zoom shortcuts.

## Requirements

- macOS (tested on modern versions)
- Swift 6.1 or later
- Accessibility permissions (will be prompted on first run)

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd zoom-pad
   ```

2. Build the project:
   ```bash
   swift build -c release
   ```

3. Run the executable:
   ```bash
   .build/release/zoom-pad
   ```

## Usage

1. Launch zoom-pad
2. Grant accessibility permissions when prompted (required for intercepting scroll events)
3. Hold the Command key and scroll on your trackpad to zoom in/out
4. The application runs in the background until terminated

## Configuration

You can modify the following constants in `zoom_pad.swift` to customize behavior:

- `triggerModifier`: Change the modifier key (default: `.maskCommand`)
- `invertScroll`: Reverse scroll direction (default: `false`)
- `stepThreshold`: Adjust scroll sensitivity (default: `85.0`)

## Permissions

This app requires **Accessibility** permissions to intercept trackpad scroll events. macOS will prompt you to grant these permissions when you first run the application.

To manually grant permissions:
1. Go to System Preferences → Security & Privacy → Privacy
2. Select "Accessibility" from the left sidebar
3. Add zoom-pad to the list of allowed applications

## Building from Source

This project uses Swift Package Manager:

```bash
# Debug build
swift build

# Release build
swift build -c release

# Run directly
swift run
```

## Technical Details

- Uses Core Graphics Event Services for low-level event interception
- Implements `CGEvent.tapCreate` for scroll wheel event monitoring
- Sends synthesized keyboard events using `CGEvent` for zoom commands
- Accumulates scroll delta values with configurable threshold for smooth operation
