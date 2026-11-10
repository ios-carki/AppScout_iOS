import Dependencies
import DependenciesMacros
import Foundation

// MARK: - 즐겨찾기

@DependencyClient
public struct FavoriteUseCase: Sendable {
    /// 즐겨찾기 목록 (최근 추가순). 목록 화면에서 `.run`으로 구독한다.
    public var observeAll: @Sendable () -> AsyncThrowingStream<[FavoriteApp], any Error> = {
        AsyncThrowingStream { $0.finish() }
    }
    /// 특정 앱의 즐겨찾기 여부. 상세 화면의 하트 버튼 상태에 사용한다.
    public var observeIsFavorite: @Sendable (_ appID: Int) -> AsyncThrowingStream<Bool, any Error> = { _ in
        AsyncThrowingStream { $0.finish() }
    }
    /// 즐겨찾기를 켜거나 끈다. 바뀐 뒤의 상태(true = 즐겨찾기됨)를 돌려준다.
    public var toggle: @Sendable (_ app: AppSummary) async throws -> Bool
    public var remove: @Sendable (_ appID: Int) async throws -> Void
}

extension FavoriteUseCase {
    public static func live(repository: any FavoriteRepository) -> Self {
        Self(
            observeAll: { repository.observeFavorites() },
            observeIsFavorite: { repository.observeIsFavorite(appID: $0) },
            toggle: { app in
                @Dependency(\.date.now) var now
                if try await repository.isFavorite(appID: app.id) {
                    try await repository.remove(appID: app.id)
                    return false
                } else {
                    try await repository.add(FavoriteApp(app, addedAt: now))
                    return true
                }
            },
            remove: { try await repository.remove(appID: $0) }
        )
    }
}

extension FavoriteUseCase: TestDependencyKey {
    public static let testValue = Self()
    public static let previewValue = Self(
        observeAll: {
            AsyncThrowingStream { continuation in
                continuation.yield(Array(FavoriteApp.mocks.prefix(3)))
            }
        },
        observeIsFavorite: { _ in
            AsyncThrowingStream { $0.yield(false) }
        },
        toggle: { _ in true },
        remove: { _ in }
    )
}

// MARK: - 최근 검색어

@DependencyClient
public struct RecentKeywordUseCase: Sendable {
    /// 최근 검색어 최대 개수
    public static let maxCount = 10

    /// 최근 검색어 (최신순). 검색 화면에서 `.run`으로 구독한다.
    public var observe: @Sendable () -> AsyncThrowingStream<[RecentKeyword], any Error> = {
        AsyncThrowingStream { $0.finish() }
    }
    /// 검색어를 저장한다. 공백뿐인 검색어는 무시한다.
    public var save: @Sendable (_ keyword: String) async throws -> Void
    public var delete: @Sendable (_ id: String) async throws -> Void
    public var deleteAll: @Sendable () async throws -> Void
}

extension RecentKeywordUseCase {
    public static func live(repository: any RecentKeywordRepository) -> Self {
        Self(
            observe: { repository.observeRecentKeywords(limit: maxCount) },
            save: { keyword in
                @Dependency(\.date.now) var now
                let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                try await repository.save(keyword: trimmed, searchedAt: now, maxCount: maxCount)
            },
            delete: { try await repository.delete(id: $0) },
            deleteAll: { try await repository.deleteAll() }
        )
    }
}

extension RecentKeywordUseCase: TestDependencyKey {
    public static let testValue = Self()
    public static let previewValue = Self(
        observe: {
            AsyncThrowingStream { $0.yield(RecentKeyword.mocks) }
        },
        save: { _ in },
        delete: { _ in },
        deleteAll: {}
    )
}

// MARK: - DependencyValues

extension DependencyValues {
    public var favoriteUseCase: FavoriteUseCase {
        get { self[FavoriteUseCase.self] }
        set { self[FavoriteUseCase.self] = newValue }
    }

    public var recentKeywordUseCase: RecentKeywordUseCase {
        get { self[RecentKeywordUseCase.self] }
        set { self[RecentKeywordUseCase.self] = newValue }
    }
}
