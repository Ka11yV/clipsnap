import AppKit
import Foundation

struct ImageWriter {
    func savePNG(_ image: NSImage, in directoryURL: URL, date: Date = Date()) throws -> URL {
        do {
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
        } catch {
            throw SnapClipError.failedToCreateDirectory
        }

        guard let pngData = image.pngData else {
            throw SnapClipError.imageEncodingFailed
        }

        let filename = Self.filenameFormatter.string(from: date)
        let fileURL = directoryURL.appendingPathComponent("snapclip-\(filename).png")

        do {
            try pngData.write(to: fileURL, options: .atomic)
        } catch {
            throw SnapClipError.failedToWriteImage
        }

        return fileURL
    }

    private static let filenameFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter
    }()
}

private extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else {
            return nil
        }

        return bitmapImage.representation(using: .png, properties: [:])
    }
}
