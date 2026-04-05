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

    private let defaults: UserDefaults
    private let clipboardImageService: ClipboardImageService
    private let imageWriter: ImageWriter
    private let destinationFolderKey = "destinationFolderPath"

    init(
        defaults: UserDefaults = .standard,
        clipboardImageService: ClipboardImageService = ClipboardImageService(),
        imageWriter: ImageWriter = ImageWriter()
    ) {
        self.defaults = defaults
        self.clipboardImageService = clipboardImageService
        self.imageWriter = imageWriter

        let initialPath = defaults.string(forKey: destinationFolderKey)
            ?? Self.defaultDestinationFolder.path

        self.destinationFolderPath = initialPath
        self.statusMessage = "Ready to configure destination folder."
        self.lastSavedFilePath = nil

        KeyboardShortcuts.onKeyUp(for: .saveClipboardImage) { [weak self] in
            Task { @MainActor in
                self?.saveClipboardImage()
            }
        }
    }

    var destinationFolderURL: URL {
        URL(fileURLWithPath: destinationFolderPath, isDirectory: true)
    }

    func chooseDestinationFolder() {
        let panel = NSOpenPanel()
        panel.title = "Choose a folder for saved images"
        panel.message = "SnapClip will save clipboard images in this folder."
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.directoryURL = destinationFolderURL

        guard panel.runModal() == .OK, let selectedURL = panel.url else {
            statusMessage = "Folder selection canceled."
            return
        }

        destinationFolderPath = selectedURL.path
        defaults.set(selectedURL.path, forKey: destinationFolderKey)
        statusMessage = "Save folder updated."
    }

    func openDestinationFolder() {
        NSWorkspace.shared.open(destinationFolderURL)
    }

    func revealLastSavedFile() {
        guard let lastSavedFilePath else { return }
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: lastSavedFilePath)])
    }

    func saveClipboardImage() {
        do {
            let image = try clipboardImageService.currentImage()
            let savedFileURL = try imageWriter.savePNG(image, in: destinationFolderURL)

            lastSavedFilePath = savedFileURL.path
            statusMessage = "Saved \(savedFileURL.lastPathComponent)."
        } catch {
            statusMessage = error.localizedDescription
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
}
