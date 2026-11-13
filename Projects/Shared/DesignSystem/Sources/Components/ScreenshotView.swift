import Kingfisher
import SwiftUI

/// 상세 화면 "미리 보기"의 스크린샷 한 장 (와이어프레임 S4 14번)
///
/// iPhone 스크린샷 비율(약 0.46)에 맞춘 185 × 400 고정 크기. 비율이 다른 이미지는 가운데를 기준으로 잘린다.
public struct ScreenshotView: View {
    public static let size = CGSize(width: 185, height: 400)

    private let url: URL?

    public init(url: URL?) {
        self.url = url
    }

    public var body: some View {
        KFImage(url)
            .placeholder { DSColor.surface }
            .setProcessor(DownsamplingImageProcessor(size: Self.size))
            .scaleFactor(UIScreen.mainScale)
            .cacheOriginalImage()
            .fade(duration: 0.2)
            .resizable()
            .scaledToFill()
            .frame(width: Self.size.width, height: Self.size.height)
            .background(.dsSurface)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.m, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DSRadius.m, style: .continuous)
                    .strokeBorder(.dsBorder, lineWidth: 0.5)
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: DSSpacing.s) {
            ScreenshotView(url: nil)
            ScreenshotView(url: nil)
        }
    }
    .contentMargins(.horizontal, DSSpacing.l)
}
