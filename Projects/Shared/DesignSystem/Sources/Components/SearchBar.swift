import SwiftUI

/// 검색 입력창.
///
/// 상태(텍스트)는 바깥(TCA State)이 소유하고, 이 컴포넌트는 바인딩과 콜백만 받는다.
/// ```swift
/// SearchBar(text: $store.searchText.sending(\.inputKeyword)) {
///     store.send(.searchButtonTapped)
/// }
/// ```
public struct SearchBar: View {
    @Binding private var text: String
    private let placeholder: String
    private let onSubmit: () -> Void
    private let onClear: (() -> Void)?

    public init(
        text: Binding<String>,
        placeholder: String = "앱 이름이나 키워드를 검색해 보세요",
        onSubmit: @escaping () -> Void = {},
        onClear: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSubmit = onSubmit
        self.onClear = onClear
    }

    public var body: some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.dsTextSecondary)
                .accessibilityHidden(true)

            TextField(
                "",
                text: $text,
                prompt: Text(placeholder).foregroundStyle(.dsTextTertiary)
            )
            .typography(.callout)
            .foregroundStyle(.dsTextPrimary)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.search)
            .onSubmit(onSubmit)

            if !text.isEmpty {
                Button {
                    if let onClear { onClear() } else { text = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.dsTextTertiary)
                        .frame(width: DSSize.minTouch, height: DSSize.minTouch)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("검색어 지우기")
            }
        }
        .padding(.leading, DSSpacing.s)
        .frame(height: DSSize.searchBar)
        .background(.dsSurface, in: RoundedRectangle(cornerRadius: DSRadius.s, style: .continuous))
    }
}

#Preview {
    struct Demo: View {
        @State var text = ""
        var body: some View {
            VStack {
                SearchBar(text: $text)
                SearchBar(text: .constant("카카오"))
            }
            .padding()
        }
    }
    return Demo()
}
