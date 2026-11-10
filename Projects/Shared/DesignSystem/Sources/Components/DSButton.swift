import SwiftUI

/// 버튼 스타일 종류
public enum DSButtonKind: Sendable {
    /// 채워진 브랜드 색 버튼 (화면의 주요 액션 1개)
    case primary
    /// 테두리만 있는 버튼 (보조 액션)
    case secondary
    /// 위험 액션 (삭제, 초기화)
    case destructive
}

/// 디자인 시스템 버튼 스타일.
/// ```swift
/// Button("저장") { store.send(.saveButtonTapped) }
///     .buttonStyle(.ds(.primary, isLoading: store.isSaving))
/// ```
public struct DSButtonStyle: ButtonStyle {
    let kind: DSButtonKind
    let isLoading: Bool
    @Environment(\.isEnabled) private var isEnabled

    public init(kind: DSButtonKind, isLoading: Bool = false) {
        self.kind = kind
        self.isLoading = isLoading
    }

    public func makeBody(configuration: Configuration) -> some View {
        ZStack {
            configuration.label
                .typography(.headline)
                .opacity(isLoading ? 0 : 1)
            if isLoading {
                ProgressView().tint(foreground)
            }
        }
        .foregroundStyle(foreground)
        .frame(maxWidth: .infinity, minHeight: DSSize.button)
        .background(background, in: shape)
        .overlay {
            if kind == .secondary {
                shape.strokeBorder(.dsBorder, lineWidth: 1)
            }
        }
        .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1) : 0.4)
        .scaleEffect(configuration.isPressed ? 0.98 : 1)
        .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
        .allowsHitTesting(!isLoading)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: DSRadius.s, style: .continuous)
    }

    private var foreground: Color {
        switch kind {
        case .primary: DSColor.onBrand
        case .secondary: DSColor.textPrimary
        case .destructive: DSColor.error
        }
    }

    private var background: Color {
        switch kind {
        case .primary: DSColor.brandPrimary
        case .secondary: .clear
        case .destructive: DSColor.error.opacity(0.1)
        }
    }
}

extension ButtonStyle where Self == DSButtonStyle {
    public static func ds(_ kind: DSButtonKind, isLoading: Bool = false) -> DSButtonStyle {
        DSButtonStyle(kind: kind, isLoading: isLoading)
    }
}

#Preview {
    VStack(spacing: DSSpacing.s) {
        Button("저장") {}.buttonStyle(.ds(.primary))
        Button("저장") {}.buttonStyle(.ds(.primary, isLoading: true))
        Button("취소") {}.buttonStyle(.ds(.secondary))
        Button("최근 검색어 전체 삭제") {}.buttonStyle(.ds(.destructive))
        Button("비활성") {}.buttonStyle(.ds(.primary)).disabled(true)
    }
    .padding()
}
