import SwiftUI

/// 설정·프로필 화면의 한 줄 항목 (제목 + 값 + 꺾쇠)
public struct DSListRow: View {
    private let title: String
    private let value: String?
    private let systemImage: String?
    private let showsChevron: Bool

    public init(
        _ title: String,
        value: String? = nil,
        systemImage: String? = nil,
        showsChevron: Bool = true
    ) {
        self.title = title
        self.value = value
        self.systemImage = systemImage
        self.showsChevron = showsChevron
    }

    public var body: some View {
        HStack(spacing: DSSpacing.s) {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(.dsBrandPrimary)
                    .frame(width: 24)
                    .accessibilityHidden(true)
            }
            Text(title)
                .typography(.body)
                .foregroundStyle(.dsTextPrimary)
            Spacer(minLength: DSSpacing.xs)
            if let value {
                Text(value)
                    .typography(.callout)
                    .foregroundStyle(.dsTextSecondary)
                    .lineLimit(1)
            }
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.dsTextTertiary)
                    .accessibilityHidden(true)
            }
        }
        .frame(minHeight: DSSize.minTouch)
        .contentShape(Rectangle())
    }
}

/// 장르 등 짧은 라벨 태그
public struct TagView: View {
    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .typography(.caption2)
            .foregroundStyle(.dsBrandSecondary)
            .padding(.horizontal, DSSpacing.xs)
            .padding(.vertical, DSSpacing.xxs / 2)
            .background(DSColor.brandSecondary.opacity(0.12), in: Capsule())
    }
}

/// 검색 결과·즐겨찾기 목록에서 쓰는 앱 셀 레이아웃
public struct AppRowView<Trailing: View>: View {
    private let iconURL: URL?
    private let title: String
    private let subtitle: String
    private let rating: Double
    private let ratingCount: Int?
    private let trailing: Trailing

    public init(
        iconURL: URL?,
        title: String,
        subtitle: String,
        rating: Double,
        ratingCount: Int? = nil,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.iconURL = iconURL
        self.title = title
        self.subtitle = subtitle
        self.rating = rating
        self.ratingCount = ratingCount
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: DSSpacing.s) {
            AppIconView(url: iconURL, size: DSSize.iconList)
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(title)
                    .typography(.headline)
                    .foregroundStyle(.dsTextPrimary)
                    .lineLimit(1)
                Text(subtitle)
                    .typography(.caption)
                    .foregroundStyle(.dsTextSecondary)
                    .lineLimit(1)
                RatingView(rating: rating, count: ratingCount)
            }
            Spacer(minLength: DSSpacing.xs)
            trailing
        }
        .padding(.vertical, DSSpacing.xs)
        .contentShape(Rectangle())
    }
}

#Preview {
    List {
        AppRowView(
            iconURL: nil,
            title: "카카오톡 KakaoTalk",
            subtitle: "소셜 네트워킹",
            rating: 3.4,
            ratingCount: 152_000
        )
        DSListRow("이름", value: "Chris", systemImage: "person")
        DSListRow("앱 버전", value: "1.0.0", showsChevron: false)
        TagView("생산성")
    }
}
