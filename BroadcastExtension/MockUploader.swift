import Foundation
import os

/// No server yet. This intentionally does not perform network I/O.
/// Replace this class later with URLSession multipart/JSON upload code.
final class MockUploader {
    private let logger = Logger(subsystem: "com.example.ScreenSampler.BroadcastExtension", category: "Uploader")

    func upload(frames: [Data]) {
        let bytes = frames.reduce(0) { $0 + $1.count }
        logger.info("MOCK POST: would upload \(frames.count) JPEG frames (\(bytes) bytes total)")
    }
}
