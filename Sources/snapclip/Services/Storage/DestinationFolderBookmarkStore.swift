import Foundation

struct DestinationFolderBookmarkStore {
    private let defaults: UserDefaults
    private let bookmarkKey = "destinationFolderBookmark"
    private let displayPathKey = "destinationFolderPath"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var displayPath: String? {
        defaults.string(forKey: displayPathKey)
    }

    var hasBookmark: Bool {
        defaults.data(forKey: bookmarkKey) != nil
    }

    func save(url: URL) throws {
        do {
            let bookmark = try url.bookmarkData(
                options: [.withSecurityScope],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )

            defaults.set(bookmark, forKey: bookmarkKey)
            defaults.set(url.path, forKey: displayPathKey)
        } catch {
            throw SnapClipError.failedToCreateBookmark
        }
    }

    func clear() {
        defaults.removeObject(forKey: bookmarkKey)
        defaults.removeObject(forKey: displayPathKey)
    }

    func resolveURL() throws -> URL {
        guard let bookmark = defaults.data(forKey: bookmarkKey) else {
            throw SnapClipError.noDestinationFolderSelected
        }

        var isStale = false

        do {
            let url = try URL(
                resolvingBookmarkData: bookmark,
                options: [.withSecurityScope],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )

            defaults.set(url.path, forKey: displayPathKey)

            if isStale {
                clear()
                throw SnapClipError.destinationBookmarkIsStale
            }

            return url
        } catch let error as SnapClipError {
            throw error
        } catch {
            throw SnapClipError.failedToResolveDestinationBookmark
        }
    }

    func withSecurityScopedAccess<T>(_ body: (URL) throws -> T) throws -> T {
        let url = try resolveURL()

        guard url.startAccessingSecurityScopedResource() else {
            throw SnapClipError.failedToAccessSecurityScopedResource
        }

        defer {
            url.stopAccessingSecurityScopedResource()
        }

        return try body(url)
    }
}
