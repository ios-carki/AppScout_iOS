import ComposableArchitecture
import DesignSystem
import Domain
import PhotosUI
import SettingsFeature
import SwiftUI

/// 프로필 화면. 와이어프레임 S9~S10
public struct ProfileView: View {
    @Bindable var store: StoreOf<ProfileFeature>

    /// PhotosPickerItem은 Equatable·Sendable이 아니라서 State가 아닌 View에 둔다.
    /// 고르면 Data로 바꿔 `photoPicked`로 보내고 바로 비운다.
    @State private var pickerItem: PhotosPickerItem?

    public init(store: StoreOf<ProfileFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.dsBackground)
                .navigationTitle("프로필")
                .toolbarTitleDisplayMode(.inlineLarge)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            store.send(.settingsButtonTapped)
                        } label: {
                            Image(systemName: "gearshape")
                                .foregroundStyle(.dsTextPrimary)
                        }
                        .accessibilityLabel("설정")
                    }
                }
        } destination: { store in
            switch store.case {
            case let .edit(store):
                EditFieldView(store: store)
            case let .settings(store):
                SettingsView(store: store)
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    store.send(.photoPicked(data))
                }
                pickerItem = nil
            }
        }
        .task { await store.send(.onAppear).finish() }
    }

    @ViewBuilder
    private var content: some View {
        if let profile = store.profile {
            profileList(profile)
        } else {
            switch store.loadState {
            case .loading, .loaded:
                LoadingView()
            case let .failed(message):
                ErrorStateView(message: message) {
                    store.send(.retryButtonTapped)
                }
            }
        }
    }

    private func profileList(_ profile: Profile) -> some View {
        List {
            header(profile)
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: DSSpacing.m, leading: 0, bottom: DSSpacing.xs, trailing: 0))

            Section("계정 정보") {
                Button {
                    store.send(.nameRowTapped)
                } label: {
                    DSListRow("이름", value: profile.name)
                }
                .buttonStyle(.plain)

                Button {
                    store.send(.emailRowTapped)
                } label: {
                    DSListRow("이메일", value: profile.email)
                }
                .buttonStyle(.plain)
            }
            .listRowBackground(Color.dsSurface)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    /// 프로필 헤더 (S9 3~7번)
    private func header(_ profile: Profile) -> some View {
        VStack(spacing: 0) {
            PhotosPicker(selection: $pickerItem, matching: .images) {
                avatar(profile)
            }
            .disabled(store.isUploadingAvatar)
            .accessibilityLabel("프로필 사진 변경")
            .padding(.bottom, DSSpacing.s)

            Text(profile.name)
                .typography(.title2)
                .foregroundStyle(.dsTextPrimary)
                .padding(.bottom, 2)

            Text(store.isUploadingAvatar ? "사진을 올리는 중…" : profile.email)
                .typography(.callout)
                .foregroundStyle(.dsTextSecondary)
        }
    }

    private func avatar(_ profile: Profile) -> some View {
        AvatarView(url: profile.avatarURL, name: profile.name)
            .overlay {
                if store.isUploadingAvatar {
                    Circle().fill(.black.opacity(0.35))
                    ProgressView().tint(.white)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "pencil")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(DSColor.onBrand)
                    .frame(width: 28, height: 28)
                    .background(.dsBrandPrimary, in: Circle())
                    .overlay { Circle().strokeBorder(.dsBackground, lineWidth: 2) }
                    .opacity(store.isUploadingAvatar ? 0.4 : 1)
                    .offset(x: 2, y: 2)
            }
    }
}

#Preview {
    ProfileView(
        store: Store(initialState: ProfileFeature.State()) {
            ProfileFeature()
        }
    )
}
