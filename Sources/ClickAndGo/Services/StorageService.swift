import Foundation

public final class StorageService {
    public static let shared = StorageService()

    private let fileManager = FileManager.default
    private let appFolderName = "ClickAndGo"
    private let fileName = "items.json"

    private var storageDirectoryURL: URL {
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return fileManager.temporaryDirectory.appendingPathComponent(appFolderName)
        }
        return appSupportURL.appendingPathComponent(appFolderName)
    }

    private var fileURL: URL {
        storageDirectoryURL.appendingPathComponent(fileName)
    }

    private init() {
        createDirectoryIfNeeded()
    }

    private func createDirectoryIfNeeded() {
        let dir = storageDirectoryURL
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        }
    }

    public func loadItems() -> [LaunchItem] {
        createDirectoryIfNeeded()
        let path = fileURL

        guard fileManager.fileExists(atPath: path.path) else {
            // First time launch: save sample items and return them
            let defaults = LaunchItem.sampleItems
            saveItems(defaults)
            return defaults
        }

        do {
            let data = try Data(contentsOf: path)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([LaunchItem].self, from: data)
        } catch {
            print("StorageService: Lỗi giải mã file cấu hình JSON: \(error)")
            // Backup broken file
            let backupURL = storageDirectoryURL.appendingPathComponent("items.json.bak")
            try? fileManager.copyItem(at: path, to: backupURL)

            // Return sample items as fallback
            return LaunchItem.sampleItems
        }
    }

    public func saveItems(_ items: [LaunchItem]) {
        createDirectoryIfNeeded()
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(items)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("StorageService: Lỗi ghi file cấu hình JSON: \(error)")
        }
    }
}
