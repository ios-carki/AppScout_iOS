import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

/// 이름·이메일 편집 화면. 와이어프레임 S11~S12
struct EditFieldView: View {
    @Bindable var store: StoreOf<EditFieldFeature>
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            field
            helper
            Spacer()
        }
        .padding(.horizontal, DSSpacing.l)
        .padding(.top, DSSpacing.m)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.dsBackground)
        .navigationTitle(store.field.title)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if store.isSaving {
                    ProgressView()
                } else {
                    Button("저장") {
                        store.send(.saveButtonTapped)
                    }
                    .fontWeight(.semibold)
                    .tint(.dsBrandPrimary)
                    .disabled(!store.canSave)
                }
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .onAppear { isFocused = true }
    }

    /// 편집 필드 (S11 5~7번)
    private var field: some View {
        HStack(spacing: 0) {
            TextField(store.field.title, text: $store.text.sending(\.textChanged))
                .typography(.body)
                .foregroundStyle(.dsTextPrimary)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit { store.send(.saveButtonTapped) }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(store.field == .email)
                .keyboardType(store.field == .email ? .emailAddress : .default)
                .textContentType(store.field == .email ? .emailAddress : .name)

            if !store.text.isEmpty && !store.isSaving {
                Button {
                    store.send(.textChanged(""))
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.dsTextTertiary)
                        .frame(width: DSSize.minTouch, height: DSSize.minTouch)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("지우기")
            }
        }
        .padding(.leading, DSSpacing.s)
        .frame(minHeight: DSSize.minTouch)
        .background(.dsSurface, in: RoundedRectangle(cornerRadius: DSRadius.s, style: .continuous))
        .overlay {
            if store.errorMessage != nil {
                RoundedRectangle(cornerRadius: DSRadius.s, style: .continuous)
                    .strokeBorder(.dsError, lineWidth: 1.5)
            }
        }
        .disabled(store.isSaving)
        .opacity(store.isSaving ? 0.6 : 1)
    }

    /// 도움말 · 글자 수 · 인라인 오류 (S11 8~9번, S12)
    @ViewBuilder
    private var helper: some View {
        if let message = store.errorMessage {
            HStack(spacing: DSSpacing.xxs) {
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 14))
                Text(message)
                    .typography(.caption)
            }
            .foregroundStyle(.dsError)
            .accessibilityElement(children: .combine)
        } else if store.field == .name {
            HStack {
                Text("\(ProfileValidator.nameLength.lowerBound)~\(ProfileValidator.nameLength.upperBound)자")
                Spacer()
                Text("\(store.trimmed.count)/\(ProfileValidator.nameLength.upperBound)")
            }
            .typography(.caption)
            .foregroundStyle(.dsTextSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        EditFieldView(
            store: Store(initialState: EditFieldFeature.State(field: .name, original: "Chris")) {
                EditFieldFeature()
            }
        )
    }
}
