import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

/// 상세 화면. 와이어프레임 S4~S6
public struct AppDetailView: View {
    @Bindable var store: StoreOf<AppDetailFeature>

    /// 스크롤해서 앱 이름이 가려지면 내비게이션 바에 제목을 보여 준다 (S4 1번 · S5 1번).
    /// 화면 표시에만 쓰이고 로직이 없으므로 리듀서가 아니라 View의 @State로 둔다.
    @State private var isTitleVisible = false

    public init(store: StoreOf<AppDetailFeature>) {
        self.store = store
    }

    /// 상세 응답이 오면 최신 요약을, 오기 전에는 목록에서 받은 요약을 쓴다
    private var summary: AppSummary {
        store.detail?.summary ?? store.app
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.bottom, DSSpacing.m)

                content
            }
            .padding(.horizontal, DSSpacing.l)
            .padding(.top, DSSpacing.xs)
            .padding(.bottom, DSSpacing.xxl)
        }
        .background(.dsBackground)
        .navigationTitle(isTitleVisible ? summary.name : "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                favoriteButton
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .task { await store.send(.onAppear).finish() }
    }

    // MARK: - 툴바 (S4 3번)

    private var favoriteButton: some View {
        Button {
            store.send(.favoriteButtonTapped)
        } label: {
            Image(systemName: store.isFavorite ? "heart.fill" : "heart")
                .foregroundStyle(.dsBrandPrimary)
        }
        .accessibilityLabel(store.isFavorite ? "즐겨찾기 해제" : "즐겨찾기 추가")
    }

    // MARK: - 헤더 (S4 5~9번) — AppSummary로 즉시 그림

    private var header: some View {
        HStack(alignment: .top, spacing: DSSpacing.s) {
            AppIconView(url: summary.iconURL, size: DSSize.iconDetail)

            VStack(alignment: .leading, spacing: 0) {
                Text(summary.name)
                    .typography(.title1)
                    .foregroundStyle(.dsTextPrimary)
                    .lineLimit(2)
                    .padding(.bottom, DSSpacing.xxs)
                    .onGeometryChange(for: Bool.self) { proxy in
                        proxy.frame(in: .scrollView).maxY < 0
                    } action: { isHidden in
                        isTitleVisible = isHidden
                    }

                Text(summary.sellerName)
                    .typography(.callout)
                    .foregroundStyle(.dsTextSecondary)
                    .lineLimit(1)
                    .padding(.bottom, DSSpacing.xs)

                RatingView(rating: summary.averageRating, count: summary.ratingCount)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: DSSize.iconDetail, alignment: .top)
    }

    // MARK: - 헤더 아래 (상태별, S6)

    @ViewBuilder
    private var content: some View {
        switch store.loadState {
        case .loading:
            skeleton

        case .loaded:
            if let detail = store.detail {
                loadedContent(detail)
            }

        case let .failed(message, canRetry):
            Group {
                if canRetry {
                    ErrorStateView(message: message) {
                        store.send(.retryButtonTapped)
                    }
                } else {
                    // 404: 다시 시도해도 결과가 같으므로 버튼 없음 (S6-D)
                    EmptyStateView(
                        systemImage: "exclamationmark.triangle",
                        title: "문제가 발생했어요",
                        message: message
                    )
                }
            }
            .padding(.top, DSSpacing.xxl)
        }
    }

    /// 로딩 스켈레톤 (S6-A) — 로딩 완료 화면과 같은 자리 · 같은 크기
    private var skeleton: some View {
        VStack(alignment: .leading, spacing: 0) {
            SkeletonBlock(width: 150, height: 18)
                .padding(.bottom, DSSpacing.m)
            SkeletonBlock(height: 70)
                .padding(.bottom, DSSpacing.m)
            SkeletonBlock(height: DSSize.button)
                .padding(.bottom, DSSpacing.xl)
            SkeletonBlock(width: 120, height: 28)
                .padding(.bottom, DSSpacing.s)
            HStack(spacing: DSSpacing.s) {
                SkeletonBlock(width: ScreenshotView.size.width, height: ScreenshotView.size.height)
                SkeletonBlock(width: ScreenshotView.size.width, height: ScreenshotView.size.height)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipped()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("불러오는 중")
    }

    // MARK: - 로딩 완료 (S4 10~14번, S5)

    private func loadedContent(_ detail: AppDetail) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if !detail.genres.isEmpty {
                tags(detail.genres)
                    .padding(.bottom, DSSpacing.m)
            }

            metrics(detail)
                .padding(.bottom, DSSpacing.m)

            if detail.appStoreURL != nil {
                Button("App Store에서 보기") {
                    store.send(.appStoreButtonTapped)
                }
                .buttonStyle(.ds(.primary))
                .padding(.bottom, DSSpacing.xl)
            }

            if !detail.screenshotURLs.isEmpty {
                screenshots(detail.screenshotURLs)
                    .padding(.bottom, DSSpacing.xl)
            }

            DescriptionSection(
                text: detail.description,
                isExpanded: store.isDescriptionExpanded
            ) {
                store.send(.descriptionMoreButtonTapped)
            }

            if let notes = detail.releaseNotes, !notes.isEmpty {
                releaseNotes(notes, detail: detail)
                    .padding(.top, DSSpacing.xl)
            }

            information(detail)
                .padding(.top, DSSpacing.xl)
        }
    }

    /// 장르 태그 (S4 10번) — 최대 3개
    private func tags(_ genres: [String]) -> some View {
        HStack(spacing: 6) {
            ForEach(genres.prefix(3), id: \.self) { genre in
                TagView(genre)
            }
        }
    }

    /// 요약 지표 4칸 (S4 11번)
    private func metrics(_ detail: AppDetail) -> some View {
        HStack(spacing: 0) {
            metricCell {
                Text(detail.summary.averageRating, format: .number.precision(.fractionLength(1)))
                    .typography(.headline)
                    .foregroundStyle(.dsTextPrimary)
                StarsView(rating: detail.summary.averageRating)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("별점 \(detail.summary.averageRating.formatted(.number.precision(.fractionLength(1))))점")

            metricDivider
            metricCell(value: RatingView.compactCount(detail.summary.ratingCount), label: "평가")
            metricDivider
            metricCell(value: detail.contentRating.isEmpty ? "-" : detail.contentRating, label: "연령")
            metricDivider
            metricCell(value: detail.summary.formattedPrice, label: "가격")
        }
        .padding(.vertical, DSSpacing.s)
        .frame(minHeight: 70)
        .overlay(alignment: .top) { hairline }
        .overlay(alignment: .bottom) { hairline }
    }

    private func metricCell(value: String, label: String) -> some View {
        metricCell {
            Text(value)
                .typography(.headline)
                .foregroundStyle(.dsTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(label)
                .typography(.caption)
                .foregroundStyle(.dsTextSecondary)
        }
        .accessibilityElement(children: .combine)
    }

    private func metricCell(@ViewBuilder _ content: () -> some View) -> some View {
        VStack(spacing: 2) {
            content()
        }
        .frame(maxWidth: .infinity)
    }

    private var metricDivider: some View {
        Rectangle()
            .fill(.dsBorder)
            .frame(width: 0.5)
            .frame(maxHeight: .infinity)
    }

    private var hairline: some View {
        Rectangle()
            .fill(.dsBorder)
            .frame(height: 0.5)
    }

    /// 미리 보기 (S4 13~14번) — 오른쪽은 화면 끝까지 스크롤
    private func screenshots(_ urls: [URL]) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            sectionTitle("미리 보기")

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: DSSpacing.s) {
                    ForEach(urls, id: \.self) { url in
                        ScreenshotView(url: url)
                    }
                }
            }
            .contentMargins(.horizontal, DSSpacing.l, for: .scrollContent)
            // 부모의 좌우 여백 20을 상쇄해서 화면 끝까지 스크롤되게 한다
            .padding(.horizontal, -DSSpacing.l)
        }
    }

    /// 새로운 기능 (S5 6~8번)
    private func releaseNotes(_ notes: String, detail: AppDetail) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack(alignment: .firstTextBaseline) {
                sectionTitle("새로운 기능")
                Spacer(minLength: DSSpacing.xs)
                Text(versionText(detail))
                    .typography(.caption)
                    .foregroundStyle(.dsTextSecondary)
                    .lineLimit(1)
            }

            Text(notes)
                .typography(.body)
                .foregroundStyle(.dsTextPrimary)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// "버전 26.9.2 · 2026.11.03"
    private func versionText(_ detail: AppDetail) -> String {
        guard let date = detail.currentVersionReleaseDate else {
            return "버전 \(detail.version)"
        }
        let formatted = date.formatted(
            .verbatim(
                "\(year: .defaultDigits).\(month: .twoDigits).\(day: .twoDigits)",
                timeZone: .current,
                calendar: Calendar(identifier: .gregorian)
            )
        )
        return "버전 \(detail.version) · \(formatted)"
    }

    /// 정보 (S5 9~10번) — 값이 없으면 "-"
    private func information(_ detail: AppDetail) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle("정보")
                .padding(.bottom, DSSpacing.xs)

            infoRow("개발사", detail.summary.sellerName)
            infoRow("크기", detail.fileSizeBytes.map { $0.formatted(.byteCount(style: .file)) })
            infoRow("연령 등급", detail.contentRating)
            infoRow("호환성", detail.minimumOSVersion.isEmpty ? nil : "iOS \(detail.minimumOSVersion) 이상")
            infoRow("장르", detail.summary.primaryGenre)
        }
    }

    private func infoRow(_ label: String, _ value: String?) -> some View {
        HStack(spacing: DSSpacing.s) {
            Text(label)
                .typography(.callout)
                .foregroundStyle(.dsTextSecondary)
            Spacer(minLength: DSSpacing.xs)
            Text(value.flatMap { $0.isEmpty ? nil : $0 } ?? "-")
                .typography(.callout)
                .foregroundStyle(.dsTextPrimary)
                .lineLimit(1)
        }
        .frame(minHeight: DSSize.minTouch)
        .overlay(alignment: .bottom) { hairline }
        .accessibilityElement(children: .combine)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .typography(.title2)
            .foregroundStyle(.dsTextPrimary)
    }
}

// MARK: - 설명 + 더 보기 (S5 3~5번)

/// "더 보기"는 3줄을 넘을 때만 보여야 한다. 넘는지는 그려 봐야 알 수 있으므로
/// 잘린 높이와 전체 높이를 재서 비교한다. 측정값은 화면 전용이라 View의 @State로 둔다.
/// 펼침 여부는 리듀서 State(`isDescriptionExpanded`)가 갖는다.
private struct DescriptionSection: View {
    let text: String
    let isExpanded: Bool
    let onMore: () -> Void

    @State private var shownHeight: CGFloat = 0
    @State private var fullHeight: CGFloat = 0

    private var isTruncated: Bool { fullHeight > shownHeight + 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("설명")
                .typography(.title2)
                .foregroundStyle(.dsTextPrimary)
                .padding(.bottom, DSSpacing.xs)

            Text(text)
                .typography(.body)
                .foregroundStyle(.dsTextPrimary)
                .lineLimit(isExpanded ? nil : 3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { shownHeight = $0 }
                .background(alignment: .topLeading) {
                    // 줄 수 제한 없이 그렸을 때의 높이 (보이지 않음)
                    Text(text)
                        .typography(.body)
                        .fixedSize(horizontal: false, vertical: true)
                        .hidden()
                        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { fullHeight = $0 }
                }

            if !isExpanded && isTruncated {
                Button(action: onMore) {
                    Text("더 보기")
                        .typography(.callout)
                        .foregroundStyle(.dsBrandPrimary)
                        .frame(height: DSSize.minTouch)
                        .padding(.leading, DSSpacing.s)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .trailing)
                // 버튼 터치 영역(44) 아래 여백을 줄여서 다음 섹션과의 간격을 16으로 맞춘다 (S5 6번)
                .padding(.bottom, -DSSpacing.xs)
            }
        }
    }
}

// MARK: - 작은 부품

/// 스켈레톤 블록 ({surface}, radius 6)
private struct SkeletonBlock: View {
    var width: CGFloat?
    let height: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: DSRadius.xs, style: .continuous)
            .fill(.dsSurface)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
    }
}

/// 별 5개만 (요약 지표 첫 칸, 별 크기 11)
private struct StarsView: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 1) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: symbol(for: index))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.dsRating)
            }
        }
        .padding(.top, 3)
    }

    private func symbol(for index: Int) -> String {
        let value = rating - Double(index)
        if value >= 0.75 { return "star.fill" }
        if value >= 0.25 { return "star.leadinghalf.filled" }
        return "star"
    }
}

// MARK: - Preview

#Preview("실제 리듀서") {
    NavigationStack {
        AppDetailView(
            store: Store(initialState: AppDetailFeature.State(app: .mock)) {
                AppDetailFeature()
            }
        )
    }
}

#Preview("로딩 완료") {
    NavigationStack {
        AppDetailView(store: .preview(loadState: .loaded, detail: .mock()))
    }
}

#Preview("스켈레톤") {
    NavigationStack {
        AppDetailView(store: .preview(loadState: .loading))
    }
}

#Preview("실패") {
    NavigationStack {
        AppDetailView(store: .preview(loadState: .failed(message: "네트워크 연결을 확인해 주세요.", canRetry: true)))
    }
}

#Preview("404") {
    NavigationStack {
        AppDetailView(store: .preview(loadState: .failed(message: "요청한 정보를 찾을 수 없어요.", canRetry: false)))
    }
}

extension StoreOf<AppDetailFeature> {
    /// 리듀서 없이 특정 상태만 그려 보는 프리뷰용 Store
    @MainActor
    fileprivate static func preview(
        loadState: AppDetailFeature.State.LoadState,
        detail: AppDetail? = nil
    ) -> StoreOf<AppDetailFeature> {
        var state = AppDetailFeature.State(app: .mock)
        state.loadState = loadState
        state.detail = detail
        return Store(initialState: state) { EmptyReducer() }
    }
}
