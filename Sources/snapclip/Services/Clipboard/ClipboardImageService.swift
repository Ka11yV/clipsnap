import AppKit

struct ClipboardImageService {
    func currentImage() throws -> NSImage {
        let pasteboard = NSPasteboard.general

        guard pasteboard.canReadObject(forClasses: [NSImage.self], options: nil),
              let image = NSImage(pasteboard: pasteboard) else {
            throw SnapClipError.noImageOnClipboard
        }

        return image
    }
}
