import ReplayKit
import CoreMedia
import QuartzCore
import os

final class SampleHandler: RPBroadcastSampleHandler {
    private let logger = Logger(subsystem: "com.example.ScreenSampler.BroadcastExtension", category: "ReplayKit")
    private let frameEncoder = FrameEncoder(maxDimension: 720, jpegQuality: 0.55)
    private let uploader = MockUploader()

    private var frameCache: [Data] = []
    private let maxCachedFrames = 7

    private let sampleInterval: CFTimeInterval = 1.0
    private let uploadInterval: CFTimeInterval = 60.0

    private var lastSampleTime: CFTimeInterval = 0
    private var lastUploadTime: CFTimeInterval = 0

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        let now = CACurrentMediaTime()
        lastSampleTime = now - sampleInterval
        lastUploadTime = now
        frameCache.removeAll(keepingCapacity: true)
        logger.info("Broadcast started")
    }

    override func broadcastPaused() {
        logger.info("Broadcast paused")
    }

    override func broadcastResumed() {
        logger.info("Broadcast resumed")
    }

    override func broadcastFinished() {
        logger.info("Broadcast finished. Cached frames: \(self.frameCache.count)")
        frameCache.removeAll(keepingCapacity: false)
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        guard sampleBufferType == .video else { return }

        // ReplayKit only guarantees this sample buffer until this method returns,
        // so encode the selected frame synchronously here instead of storing it.
        let now = CACurrentMediaTime()
        guard now - lastSampleTime >= sampleInterval else { return }
        lastSampleTime = now

        autoreleasepool {
            guard let jpeg = frameEncoder.encodeJPEG(from: sampleBuffer) else {
                logger.error("Could not encode video frame")
                return
            }

            frameCache.append(jpeg)
            if frameCache.count > maxCachedFrames {
                frameCache.removeFirst(frameCache.count - maxCachedFrames)
            }

            logger.debug("Captured JPEG. Cache=\(self.frameCache.count), bytes=\(jpeg.count)")
        }

        if now - lastUploadTime >= uploadInterval {
            lastUploadTime = now
            let batch = frameCache
            uploader.upload(frames: batch)
        }
    }
}
