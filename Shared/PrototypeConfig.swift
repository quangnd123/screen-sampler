import Foundation

enum PrototypeConfig {
    static let appGroup = "group.com.example.ScreenSampler"
    static let backendURL = URL(string: "http://192.168.1.2:8000/analyze")!
    static let captureIntervalSeconds = 1.0
    static let rollingFrameCount = 7
    static let analysisIntervalSeconds = 30.0
    static let resizeMaxDimension: CGFloat = 512
    static let jpegQuality: CGFloat = 0.55
    static let maxStoredNotifications = 5
    static let requestTimeoutSeconds = 25.0
}
