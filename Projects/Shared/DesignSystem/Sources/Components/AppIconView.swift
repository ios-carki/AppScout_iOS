import Kingfisher
import SwiftUI

/// 원격 앱 아이콘 이미지 (Kingfisher 메모리·디스크 캐시 사용)
///
/// - AsyncImage는 캐시가 없어서 리스트를 스크롤할 때마다 다시 내려받는다. 그래서 Kingfisher를 쓴다.
/// - 다운샘플링으로 표시 크기만큼만 디코딩해서 메모리를 아낀다.
public struct AppIconView: View {
    private let url: URL?
    private let size: CGFloat

    public init(url: URL?, size: CGFloat = DSSize.iconList) {
        self.url = url
        self.size = size
    }

    public var body: some View {
        KFImage(url)
            .placeholder { placeholder }
            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: size, height: size)))
            .scaleFactor(UIScreen.mainScale)
            .cacheOriginalImage()
            .fade(duration: 0.2)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.appIcon(size: size), style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DSRadius.appIcon(size: size), style: .continuous)
                    .strokeBorder(.dsBorder, lineWidth: 0.5)
            }
            .accessibilityHidden(true)
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: DSRadius.appIcon(size: size), style: .continuous)
            .fill(.dsSurface)
            .overlay {
                Image(systemName: "app.dashed")
                    .font(.system(size: size * 0.35))
                    .foregroundStyle(.dsTextTertiary)
            }
    }
}

extension UIScreen {
    /// 화면 배율. `UIScreen.main`은 iOS 16부터 deprecated라서 trait 기반 값을 쓴다.
    static var mainScale: CGFloat {
        UITraitCollection.current.displayScale > 0 ? UITraitCollection.current.displayScale : 3
    }
}

#Preview {
    HStack(spacing: DSSpacing.m) {
        AppIconView(url: nil)
        AppIconView(url: nil, size: DSSize.iconDetail)
    }
    .padding()
}
