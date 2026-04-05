import AppKit
import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var statusMessage: String
    @Published var destinationFolderPath: String
    @Published var lastSavedFilePath: String?

    private let defaults: UserDefaults
    private let destinationFolderKey = "destinationFolderPath"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let initialPath = defaults.string(forKey: destinationFolderKey)
            ?? Self.defaultDestinationFolder.path

        self.destinationFolderPath = initialPath
        self.statusMessage = "Ready to configure destination folder."
        self.lastSavedFilePath = nil
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
        statusMessage = "Save action will be added next."
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
