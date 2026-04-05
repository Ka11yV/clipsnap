import Foundation

enum SnapClipError: LocalizedError {
    case noImageOnClipboard
    case imageEncodingFailed
    case failedToCreateDirectory
    case failedToWriteImage

    var errorDescription: String? {
        switch self {
        case .noImageOnClipboard:
            return "No image is available on the clipboard."
        case .imageEncodingFailed:
            return "The clipboard image could not be encoded as PNG."
        case .failedToCreateDirectory:
            return "SnapClip could not create the destination folder."
        case .failedToWriteImage:
            return "SnapClip could not write the image file to disk."
        }
    }
}
