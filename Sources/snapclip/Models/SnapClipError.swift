import Foundation

enum SnapClipError: LocalizedError {
    case noImageOnClipboard
    case noDestinationFolderSelected
    case failedToCreateBookmark
    case failedToResolveDestinationBookmark
    case destinationBookmarkIsStale
    case failedToAccessSecurityScopedResource
    case imageEncodingFailed
    case failedToCreateDirectory
    case failedToWriteImage

    var errorDescription: String? {
        switch self {
        case .noImageOnClipboard:
            return "No image is available on the clipboard."
        case .noDestinationFolderSelected:
            return "Choose a save folder before saving clipboard images."
        case .failedToCreateBookmark:
            return "SnapClip could not save sandbox access for the selected folder."
        case .failedToResolveDestinationBookmark:
            return "SnapClip could not restore access to the selected save folder."
        case .destinationBookmarkIsStale:
            return "The selected save folder needs to be approved again."
        case .failedToAccessSecurityScopedResource:
            return "SnapClip could not access the selected save folder in the sandbox."
        case .imageEncodingFailed:
            return "The clipboard image could not be encoded as PNG."
        case .failedToCreateDirectory:
            return "SnapClip could not create the destination folder."
        case .failedToWriteImage:
            return "SnapClip could not write the image file to disk."
        }
    }
}
