import AppDetailFeature
import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

/// 검색 화면. 와이어프레임 S1~S3
public struct SearchView: View {
    @Bindable var store: StoreOf<SearchFeature>

    public init(store: StoreOf<SearchFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack(spacing: 0) {
                SearchBar(text: $store.searchText.sending(\.inputKeyword)) {
                    store.send(.searchButtonTapped)
                } onClear: {
                    store.send(.inputKeyword(""))
                }
                .padding(.horizontal, DSSpacing.l)
                .padding(.top, DSSpacing.xs)
                .padding(.bottom, DSSpacing.s)

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(.dsBackground)
            .navigationTitle("검색")
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

    // MARK: - 상태별 콘텐츠 (S1 · S2 · S3)

    @ViewBuilder
    private var content: some View {
        switch store.loadState {
        case .idle:
            if store.recentSearch.isEmpty {
                EmptyStateView(
                    systemImage: "magnifyingglass",
                    title: "어떤 앱을 찾고 있나요?",
                    message: "앱 이름, 개발사, 장르로 검색할 수 있어요."
                )
            } else {
                recentSection
            }

        case .loading:
            LoadingView()

        case .loaded:
            resultList

        case .empty:
            EmptyStateView(
                systemImage: "magnifyingglass",
                title: "‘\(store.searchedKeyword)’ 검색 결과가 없어요",
                message: "철자를 확인하거나 다른 키워드로 검색해 보세요."
            )

        case let .failed(message):
            ErrorStateView(message: message) {
                store.send(.retryButtonTapped)
            }
        }
    }

    // MARK: - S1 최근 검색어

    private var recentSection: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Text("최근 검색어")
                        .typography(.headline)
                        .foregroundStyle(.dsTextPrimary)

                    Spacer()

                    Button {
                        store.send(.deleteAllRecentSearch)
                    } label: {
                        Text("전체 삭제")
                            .typography(.callout)
                            .foregroundStyle(.dsBrandPrimary)
                            .frame(height: DSSize.minTouch)
                    }
                    .buttonStyle(.plain)
                }

                ForEach(store.recentSearch) { recent in
                    recentRow(recent)
                }
            }
            .padding(.horizontal, DSSpacing.l)
        }
        .scrollDismissesKeyboard(.immediately)
    }

    private func recentRow(_ recent: RecentKeyword) -> some View {
        HStack(spacing: 0) {
            Button {
                store.send(.cellTapped(recent))
            } label: {
                HStack(spacing: DSSpacing.s) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 18))
                        .foregroundStyle(.dsTextSecondary)

                    Text(recent.keyword)
                        .typography(.body)
                        .foregroundStyle(.dsTextPrimary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: DSSize.minTouch)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)

            Button {
                store.send(.deleteRow(recent.id))
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15))
                    .foregroundStyle(.dsTextTertiary)
                    .frame(width: DSSize.minTouch, height: DSSize.minTouch)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(recent.keyword) 삭제")
        }
    }

    // MARK: - S2 결과 목록

    private var resultList: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("검색 결과 \(store.total)개")
                .typography(.caption)
                .foregroundStyle(.dsTextSecondary)
                .padding(.horizontal, DSSpacing.l)

            List {
                ForEach(store.searchResults) { app in
                    Button {
                        store.send(.resultTapped(app))
                    } label: {
                        AppRowView(
                            iconURL: app.iconURL,
                            title: app.name,
                            subtitle: "\(app.primaryGenre) · \(app.sellerName)",
                            rating: app.averageRating,
                            ratingCount: app.ratingCount
                        ) {
                            Text(app.formattedPrice)
                                .typography(.caption)
                                .foregroundStyle(.dsTextSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 0, leading: DSSpacing.l, bottom: 0, trailing: DSSpacing.l))
                    .listRowBackground(Color.dsBackground)
                    .listRowSeparatorTint(.dsBorder)
                    .onAppear { store.send(.rowAppeared(app.id)) }
                }

                listFooter
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.dsBackground)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.immediately)
        }
    }

    /// 목록 하단 상태 (C5): 불러오는 중 / 실패 + 다시 시도 / 끝
    private var listFooter: some View {
        HStack(spacing: DSSpacing.xs) {
            if store.isLoadingNextPage {
                ProgressView()
                    .controlSize(.small)
                Text("불러오는 중")
                    .typography(.caption)
                    .foregroundStyle(.dsTextSecondary)
            } else if store.isNextPageFailed {
                Text("더 불러오지 못했어요.")
                    .typography(.caption)
                    .foregroundStyle(.dsTextSecondary)
                Button {
                    store.send(.nextPageRetryButtonTapped)
                } label: {
                    Text("다시 시도")
                        .typography(.callout)
                        .foregroundStyle(.dsBrandPrimary)
                        .padding(.horizontal, DSSpacing.xs)
                        .frame(height: DSSize.minTouch)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
            } else if store.nextPage == nil {
                Text("모든 결과를 확인했어요")
                    .typography(.caption)
                    .foregroundStyle(.dsTextTertiary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 52)
    }
}

#Preview {
    SearchView(
        store: Store(initialState: SearchFeature.State()) {
            SearchFeature()
        }
    )
}
