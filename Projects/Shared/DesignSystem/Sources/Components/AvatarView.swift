import Kingfisher
import SwiftUI

/// 원형 프로필 이미지. 이미지가 없으면 이름 첫 글자를 보여 준다 (와이어프레임 S9 4번)
public struct AvatarView: View {
    private let url: URL?
    private let name: String
    private let size: CGFloat

    public init(url: URL?, name: String, size: CGFloat = DSSize.avatar) {
        self.url = url
        self.name = name
        self.size = size
    }

    public var body: some View {
        Group {
            if let url {
                KFImage(url)
                    .placeholder { initial }
                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: size, height: size)))
                    .scaleFactor(UIScreen.mainScale)
                    .fade(duration: 0.2)
                    .resizable()
                    .scaledToFill()
            } else {
                initial
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .accessibilityHidden(true)
    }

    private var initial: some View {
        ZStack {
            DSColor.brandPrimary.opacity(0.12)
            Text(name.first.map(String.init) ?? "")
                .font(.custom(DSFontWeight.bold.fontName, size: size * 0.39))
                .foregroundStyle(.dsBrandPrimary)
        }
    }
}

#Preview {
    HStack(spacing: DSSpacing.m) {
        AvatarView(url: nil, name: "Chris")
        AvatarView(url: nil, name: "김철수", size: 44)
    }
    .padding()
}
