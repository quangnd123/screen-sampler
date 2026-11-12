import Foundation
import UserNotifications

struct StoredResult: Codable, Identifiable {
    let requestID: String
    let word: String
    let senseIndex: Int
    let meaning: String
    let createdAt: Date
    var id: String { requestID }
}

enum ResultStore {
    private static var folder: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: PrototypeConfig.appGroup)?.appendingPathComponent("Results", isDirectory: true)
    }

    static func load(_ id: String) -> (StoredResult, Data)? {
        guard let folder, UUID(uuidString: id) != nil,
              let metadata = try? Data(contentsOf: folder.appendingPathComponent(id + ".json")),
              let result = try? JSONDecoder().decode(StoredResult.self, from: metadata),
              let image = try? Data(contentsOf: folder.appendingPathComponent(id + ".jpg")) else { return nil }
        return (result, image)
    }

    static func save(_ result: StoredResult, image: Data) -> Bool {
        guard let folder else { return false }
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try image.write(to: folder.appendingPathComponent(result.id + ".jpg"), options: .atomic)
            try JSONEncoder().encode(result).write(to: folder.appendingPathComponent(result.id + ".json"), options: .atomic)
            let files = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
            let results = files.filter { $0.pathExtension == "json" }.compactMap { file -> StoredResult? in
                guard let data = try? Data(contentsOf: file) else { return nil }
                return try? JSONDecoder().decode(StoredResult.self, from: data)
            }.sorted { $0.createdAt > $1.createdAt }
            for old in results.dropFirst(PrototypeConfig.maxStoredNotifications) {
                try? FileManager.default.removeItem(at: folder.appendingPathComponent(old.id + ".json"))
                try? FileManager.default.removeItem(at: folder.appendingPathComponent(old.id + ".jpg"))
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [old.id])
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [old.id])
            }
            return true
        } catch {
            return false
        }
    }
}
