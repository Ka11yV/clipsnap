# snapclip

SnapClip is a macOS menu bar utility that saves the current clipboard image into a folder you choose.

## What it does

- Watches for a user-configurable shortcut.
- Reads the current image from the macOS clipboard.
- Saves the image as a PNG file with a timestamped name.
- Lets you choose and update the destination folder from the Settings screen.

## Default behavior

- Default save folder: `~/Pictures/ClipSnap`
- Default filename format: `snapclip-YYYYMMdd-HHmmss.png`
- Save format: PNG

## Requirements

- macOS 13 or newer
- Swift 6.2 toolchain / Xcode with Swift Package Manager support

## Run the app

### From Terminal

```bash
swift run
```

### From Xcode

1. Open `Package.swift` in Xcode.
2. Build and run the `snapclip` executable target.

## How to use

1. Run the app.
2. Open **Settings** from the menu bar item.
3. Choose the folder where copied images should be saved.
4. Record your preferred shortcut in the **Shortcut** section.
5. Copy an image with `⌘C`.
6. Press your configured shortcut.
7. The image will be saved into the configured folder.

You can also use the **Save Clipboard Image** action directly from the menu bar window.

## Project structure

```text
Sources/snapclip/
├── App/
│   └── AppState.swift
├── Models/
│   └── SnapClipError.swift
├── Services/
│   ├── Clipboard/
│   │   └── ClipboardImageService.swift
│   └── Storage/
│       └── ImageWriter.swift
├── UI/
│   ├── MenuBarView.swift
│   └── SettingsView.swift
└── snapclip.swift
```

## Notes

- If the clipboard does not currently contain an image, the save request will fail with a status message.
- The app creates the destination folder automatically if it does not exist.
- Shortcut recording and global shortcut handling are powered by [`KeyboardShortcuts`](https://github.com/sindresorhus/KeyboardShortcuts).
