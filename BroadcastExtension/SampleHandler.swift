import ReplayKit
import CoreMedia
import QuartzCore

final class SampleHandler: RPBroadcastSampleHandler {
    private let encoder = FrameEncoder(maxDimension: PrototypeConfig.resizeMaxDimension, jpegQuality: PrototypeConfig.jpegQuality)
    private let analyzer = Analyzer()
    private var frames: [Data] = []
    private var lastSample = 0.0
    private var lastAnalysis = 0.0
    private var paused = false

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        let now = CACurrentMediaTime()
        lastSample = now - PrototypeConfig.captureIntervalSeconds
        lastAnalysis = now
        frames.removeAll()
        paused = false
    }

    override func broadcastPaused() { paused = true }
    override func broadcastResumed() { paused = false }
    override func broadcastFinished() {
        analyzer.stop()
        frames.removeAll()
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        guard sampleBufferType == .video, !paused else { return }
        if UserDefaults(suiteName: PrototypeConfig.appGroup)?.bool(forKey: "stopRequested") == true {
            analyzer.stop()
            finishBroadcastWithError(NSError(domain: "ScreenSampler", code: 0, userInfo: [NSLocalizedDescriptionKey: "Broadcast stopped by user"]))
            return
        }
        let now = CACurrentMediaTime()
        if now - lastSample >= PrototypeConfig.captureIntervalSeconds {
            lastSample = now
            autoreleasepool {
                if let jpeg = encoder.encodeJPEG(from: sampleBuffer) {
                    frames.append(jpeg)
                    if frames.count > PrototypeConfig.rollingFrameCount { frames.removeFirst() }
                }
            }
        }
        if now - lastAnalysis >= PrototypeConfig.analysisIntervalSeconds {
            lastAnalysis = now
            analyzer.analyze(frames)
        }
    }
}
