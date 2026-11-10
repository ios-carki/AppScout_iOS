import SwiftUI

/// 빈 상태 화면 (검색 결과 없음, 즐겨찾기 없음 등)
public struct EmptyStateView: View {
    private let systemImage: String
    private let title: String
    private let message: String?
    private let actionTitle: String?
    private let action: (() -> Void)?

    public init(
        systemImage: String,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: DSSpacing.s) {
            Image(systemName: systemImage)
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(.dsTextTertiary)
                .padding(.bottom, DSSpacing.xs)
                .accessibilityHidden(true)
            Text(title)
                .typography(.headline)
                .foregroundStyle(.dsTextPrimary)
            if let message {
                Text(message)
                    .typography(.callout)
                    .foregroundStyle(.dsTextSecondary)
            }
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.ds(.secondary))
                    .frame(maxWidth: 200)
                    .padding(.top, DSSpacing.xs)
            }
        }
        .multilineTextAlignment(.center)
        .padding(DSSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 에러 상태 화면 (재시도 버튼 포함)
public struct ErrorStateView: View {
    private let message: String
    private let retry: () -> Void

    public init(message: String, retry: @escaping () -> Void) {
        self.message = message
        self.retry = retry
    }

    public var body: some View {
        EmptyStateView(
            systemImage: "exclamationmark.triangle",
            title: "문제가 발생했어요",
            message: message,
            actionTitle: "다시 시도",
            action: retry
        )
    }
}

/// 로딩 상태 화면
public struct LoadingView: View {
    private let message: String?

    public init(message: String? = nil) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: DSSpacing.s) {
            ProgressView()
                .controlSize(.large)
                .tint(.dsBrandPrimary)
            if let message {
                Text(message)
                    .typography(.callout)
                    .foregroundStyle(.dsTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Empty") {
    EmptyStateView(
        systemImage: "magnifyingglass",
        title: "검색 결과가 없어요",
        message: "다른 키워드로 검색해 보세요."
    )
}

#Preview("Error") {
    ErrorStateView(message: "네트워크 연결을 확인해 주세요.") {}
}

#Preview("Loading") {
    LoadingView(message: "불러오는 중…")
}
