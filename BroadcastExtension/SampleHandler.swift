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
        let shared = UserDefaults(suiteName: PrototypeConfig.appGroup)
        shared?.set(false, forKey: "stopRequested")
        shared?.set(true, forKey: "broadcastActive")
        shared?.set(Date().addingTimeInterval(PrototypeConfig.analysisIntervalSeconds).timeIntervalSince1970, forKey: "nextAnalysisAt")
        shared?.set("Đang thu thập ảnh", forKey: "analysisStatus")
        ActivityLog.append("Broadcast bắt đầu; request đầu sau 10 giây")
    }

    override func broadcastPaused() {
        paused = true
        ActivityLog.append("Broadcast tạm dừng")
        UserDefaults(suiteName: PrototypeConfig.appGroup)?.set("Đã tạm dừng", forKey: "analysisStatus")
    }
    override func broadcastResumed() {
        paused = false
        lastAnalysis = CACurrentMediaTime()
        let shared = UserDefaults(suiteName: PrototypeConfig.appGroup)
        shared?.set(Date().addingTimeInterval(PrototypeConfig.analysisIntervalSeconds).timeIntervalSince1970, forKey: "nextAnalysisAt")
        shared?.set("Đang thu thập ảnh", forKey: "analysisStatus")
        ActivityLog.append("Broadcast tiếp tục")
    }
    override func broadcastFinished() {
        analyzer.stop()
        frames.removeAll()
        let shared = UserDefaults(suiteName: PrototypeConfig.appGroup)
        shared?.set(false, forKey: "broadcastActive")
        shared?.removeObject(forKey: "nextAnalysisAt")
        shared?.set("Đã dừng", forKey: "analysisStatus")
        ActivityLog.append("Broadcast đã dừng")
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        guard sampleBufferType == .video, !paused else { return }
        if UserDefaults(suiteName: PrototypeConfig.appGroup)?.bool(forKey: "stopRequested") == true {
            analyzer.stop()
            UserDefaults(suiteName: PrototypeConfig.appGroup)?.set(false, forKey: "broadcastActive")
            ActivityLog.append("Người dùng yêu cầu dừng")
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
            let shared = UserDefaults(suiteName: PrototypeConfig.appGroup)
            shared?.set(Date().addingTimeInterval(PrototypeConfig.analysisIntervalSeconds).timeIntervalSince1970, forKey: "nextAnalysisAt")
            shared?.set(frames.count == PrototypeConfig.rollingFrameCount ? "Đang gửi request" : "Chưa đủ 7 ảnh", forKey: "analysisStatus")
            ActivityLog.append(frames.count == PrototypeConfig.rollingFrameCount ? "Gửi 7 ảnh tới server" : "Bỏ qua: mới có \(frames.count)/7 ảnh")
            analyzer.analyze(frames)
        }
    }
}
