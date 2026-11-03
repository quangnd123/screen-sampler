import CoreMedia
import CoreImage
import UIKit

final class FrameEncoder {
    private let context = CIContext(options: [.cacheIntermediates: false])
    private let maxDimension: CGFloat
    private let jpegQuality: CGFloat

    init(maxDimension: CGFloat, jpegQuality: CGFloat) {
        self.maxDimension = maxDimension
        self.jpegQuality = jpegQuality
    }

    func encodeJPEG(from sampleBuffer: CMSampleBuffer) -> Data? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }

        let source = CIImage(cvPixelBuffer: pixelBuffer)
        let width = source.extent.width
        let height = source.extent.height
        let longestSide = max(width, height)

        guard longestSide > 0 else { return nil }

        let scale = min(1.0, maxDimension / longestSide)
        let scaled = source.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage).jpegData(compressionQuality: jpegQuality)
    }
}
