import Foundation
import ImageIO
import UniformTypeIdentifiers

/// 업로드용 이미지 압축기.
///
/// ImageIO의 썸네일 API로 원본 전체를 디코딩하지 않고 바로 축소한다. (큰 HEIC도 메모리 부담이 적음)
/// 강의 코드처럼 60×60 썸네일을 그대로 저장하는 문제를 피하기 위해, 목적에 맞는 크기를 명시적으로 정한다.
public struct ImageCompressor: Sendable {
    /// 긴 변 최대 픽셀
    public var maxPixelSize: Int
    /// JPEG 품질 (0~1)
    public var quality: Double

    public static let `default` = ImageCompressor(maxPixelSize: 1024, quality: 0.8)

    public init(maxPixelSize: Int, quality: Double) {
        self.maxPixelSize = maxPixelSize
        self.quality = quality
    }

    /// 이미지를 JPEG로 축소한다. 이미지로 읽을 수 없는 데이터면 nil.
    public func compress(_ data: Data) -> Data? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true, // EXIF 회전 반영
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            output, UTType.jpeg.identifier as CFString, 1, nil
        ) else { return nil }
        CGImageDestinationAddImage(
            destination, image,
            [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary
        )
        guard CGImageDestinationFinalize(destination) else { return nil }
        return output as Data
    }
}
