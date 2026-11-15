import Foundation

/// Small text-only log shared by the app and its broadcast extension.
enum ActivityLog {
    private static let key = "activityLog"
    private static let lock = NSLock()
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    static func append(_ message: String) {
        lock.lock()
        defer { lock.unlock() }
        guard let shared = UserDefaults(suiteName: PrototypeConfig.appGroup) else { return }
        var entries = shared.stringArray(forKey: key) ?? []
        entries.append("\(formatter.string(from: Date()))  \(message)")
        shared.set(Array(entries.suffix(40)), forKey: key)
    }

    static func entries() -> [String] {
        UserDefaults(suiteName: PrototypeConfig.appGroup)?.stringArray(forKey: key) ?? []
    }

    static func clear() {
        UserDefaults(suiteName: PrototypeConfig.appGroup)?.removeObject(forKey: key)
    }
}
