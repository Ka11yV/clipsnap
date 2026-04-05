import AppKit
import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let saveClipboardImage = Self("saveClipboardImage")
}

@MainActor
final class AppState: ObservableObject {
    @Published var statusMessage: String
    @Published var destinationFolderPath: String
    @Published var lastSavedFilePath: String?
    @Published private(set) var hasDestinationFolderAccess: Bool

    private let defaults: UserDefaults
    private let clipboardImageService: ClipboardImageService
    private let imageWriter: ImageWriter
    private let bookmarkStore: DestinationFolderBookmarkStore
    private let destinationFolderKey = "destinationFolderPath"

    init(
        defaults: UserDefaults = .standard,
        clipboardImageService: ClipboardImageService = ClipboardImageService(),
        imageWriter: ImageWriter = ImageWriter(),
        bookmarkStore: DestinationFolderBookmarkStore? = nil
    ) {
        self.defaults = defaults
        self.clipboardImageService = clipboardImageService
        self.imageWriter = imageWriter
        self.bookmarkStore = bookmarkStore ?? DestinationFolderBookmarkStore(defaults: defaults)

        let initialPath = defaults.string(forKey: destinationFolderKey)
            ?? "Choose a folder in Settings to enable sandboxed saves."

        self.destinationFolderPath = initialPath
        self.statusMessage = "Choose a folder in Settings to enable sandboxed saves."
        self.lastSavedFilePath = nil
        self.hasDestinationFolderAccess = false

        refreshDestinationFolderAccessStatus()

        KeyboardShortcuts.onKeyUp(for: .saveClipboardImage) { [weak self] in
            Task { @MainActor in
                self?.saveClipboardImage()
            }
        }
    }

    var destinationFolderURL: URL {
        URL(fileURLWithPath: destinationFolderPath, isDirectory: true)
    }

    var destinationFolderDescription: String {
        if hasDestinationFolderAccess {
            return "SnapClip can save to this folder using sandbox access."
        }

        return "Choose a folder to grant sandbox-safe write access."
    }

    var canRevealLastSavedFile: Bool {
        hasDestinationFolderAccess && lastSavedFilePath != nil
    }

    func chooseDestinationFolder() {
        let panel = NSOpenPanel()
        panel.title = "Choose a folder for saved images"
        panel.message = "SnapClip will store sandbox access for this folder and save clipboard images there."
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.directoryURL = hasDestinationFolderAccess ? destinationFolderURL : Self.defaultDestinationFolder

        guard panel.runModal() == .OK, let selectedURL = panel.url else {
            statusMessage = "Folder selection canceled."
            return
        }

        do {
            try bookmarkStore.save(url: selectedURL)
            defaults.removeObject(forKey: destinationFolderKey)
            destinationFolderPath = selectedURL.path
            hasDestinationFolderAccess = true
            statusMessage = "Save folder updated with sandbox access."
        } catch {
            hasDestinationFolderAccess = false
            statusMessage = error.localizedDescription
        }
    }

    func openDestinationFolder() {
        do {
            _ = try bookmarkStore.withSecurityScopedAccess { folderURL in
                NSWorkspace.shared.open(folderURL)
            }
        } catch {
            statusMessage = error.localizedDescription
            refreshDestinationFolderAccessStatus()
        }
    }

    func revealLastSavedFile() {
        guard let lastSavedFilePath else { return }

        do {
            _ = try bookmarkStore.withSecurityScopedAccess { _ in
                NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: lastSavedFilePath)])
            }
        } catch {
            statusMessage = error.localizedDescription
            refreshDestinationFolderAccessStatus()
        }
    }

    func saveClipboardImage() {
        do {
            guard hasDestinationFolderAccess else {
                throw SnapClipError.noDestinationFolderSelected
            }

            let image = try clipboardImageService.currentImage()
            let savedFileURL = try bookmarkStore.withSecurityScopedAccess { folderURL in
                try imageWriter.savePNG(image, in: folderURL)
            }

            lastSavedFilePath = savedFileURL.path
            statusMessage = "Saved \(savedFileURL.lastPathComponent)."
        } catch {
            statusMessage = error.localizedDescription
            refreshDestinationFolderAccessStatus()
        }
    }

    func quit() {
        NSApplication.shared.terminate(nil)
    }

    private static var defaultDestinationFolder: URL {
        let picturesDirectory = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first
        return (picturesDirectory ?? URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true))
            .appendingPathComponent("ClipSnap", isDirectory: true)
    }

    private func refreshDestinationFolderAccessStatus() {
        do {
            let resolvedURL = try bookmarkStore.resolveURL()
            destinationFolderPath = resolvedURL.path
            hasDestinationFolderAccess = true

            if statusMessage == "Choose a folder in Settings to enable sandboxed saves." {
                statusMessage = "Ready to save clipboard images."
            }
        } catch {
            hasDestinationFolderAccess = false

            if let legacyPath = bookmarkStore.displayPath {
                destinationFolderPath = legacyPath
            } else {
                destinationFolderPath = "Choose a folder in Settings to enable sandboxed saves."
            }

            if !(error is SnapClipError) {
                statusMessage = "Choose a folder in Settings to enable sandboxed saves."
                return
            }

            statusMessage = error.localizedDescription
        }
    }
}
