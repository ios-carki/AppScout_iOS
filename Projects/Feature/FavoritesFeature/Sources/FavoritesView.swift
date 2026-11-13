import AppDetailFeature
import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

/// 즐겨찾기 화면. 와이어프레임 S7~S8
public struct FavoritesView: View {
    @Bindable var store: StoreOf<FavoritesFeature>

    public init(store: StoreOf<FavoritesFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.dsBackground)
                .navigationTitle("즐겨찾기")
                .toolbarTitleDisplayMode(.inlineLarge)
        } destination: { store in
            switch store.case {
            case let .detail(store):
                AppDetailView(store: store)
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .task { await store.send(.onAppear).finish() }
    }

    @ViewBuilder
    private var content: some View {
        switch store.loadState {
        case .loading:
            // 로컬 DB라 거의 즉시 끝나므로 스피너 대신 빈 화면 (깜빡임 방지)
            Color.clear

        case .loaded where store.favorites.isEmpty:
            EmptyStateView(
                systemImage: "heart",
                title: "아직 즐겨찾기한 앱이 없어요",
                message: "앱 상세에서 ♡를 눌러 모아 보세요.",
                actionTitle: "앱 검색하러 가기"
            ) {
                store.send(.searchButtonTapped)
            }

        case .loaded:
            favoriteList

        case let .failed(message):
            ErrorStateView(message: message) {
                store.send(.retryButtonTapped)
            }
        }
    }

    /// S7 목록 — 스와이프 삭제는 List에서만 동작한다
    private var favoriteList: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("\(store.favorites.count)개 · 최근 추가순")
                .typography(.caption)
                .foregroundStyle(.dsTextSecondary)
                .padding(.horizontal, DSSpacing.l)
                .padding(.top, DSSpacing.xs)

            List {
                ForEach(store.favorites) { favorite in
                    Button {
                        store.send(.cellTapped(favorite))
                    } label: {
                        AppRowView(
                            iconURL: favorite.iconURL,
                            title: favorite.name,
                            subtitle: "\(favorite.primaryGenre) · \(favorite.sellerName)",
                            rating: favorite.averageRating
                        )
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 0, leading: DSSpacing.l, bottom: 0, trailing: DSSpacing.l))
                    .listRowBackground(Color.dsBackground)
                    .listRowSeparatorTint(.dsBorder)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            store.send(.deleteSwiped(id: favorite.id))
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                        .tint(.dsError)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}

#Preview {
    FavoritesView(
        store: Store(initialState: FavoritesFeature.State()) {
            FavoritesFeature()
        }
    )
}
