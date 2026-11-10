import Foundation

// Repository 프로토콜은 Domain에 두고, 구현(RepositoryImpl)은 Data 모듈에 둔다.
// 모든 메서드는 실패 시 `DomainError`를 던진다.

/// 서버의 앱 정보
public protocol AppRepository: Sendable {
    func searchApps(term: String, page: PageRequest) async throws -> Page<AppSummary>
    func fetchAppDetail(id: Int) async throws -> AppDetail
}

/// 서버의 사용자 프로필
public protocol ProfileRepository: Sendable {
    func fetchProfile() async throws -> Profile
    func updateProfile(name: String?, email: String?) async throws -> Profile
    func uploadAvatar(imageData: Data) async throws -> Profile
}

/// 로컬 DB의 즐겨찾기
public protocol FavoriteRepository: Sendable {
    /// 즐겨찾기 목록 (최근 추가순). DB가 바뀔 때마다 새 값을 방출한다.
    func observeFavorites() -> AsyncThrowingStream<[FavoriteApp], any Error>
    /// 특정 앱의 즐겨찾기 여부. DB가 바뀔 때마다 새 값을 방출한다.
    func observeIsFavorite(appID: Int) -> AsyncThrowingStream<Bool, any Error>
    func isFavorite(appID: Int) async throws -> Bool
    func add(_ app: FavoriteApp) async throws
    func remove(appID: Int) async throws
}

/// 로컬 DB의 최근 검색어
public protocol RecentKeywordRepository: Sendable {
    /// 최근 검색어 (최신순, 최대 `limit`개). DB가 바뀔 때마다 새 값을 방출한다.
    func observeRecentKeywords(limit: Int) -> AsyncThrowingStream<[RecentKeyword], any Error>
    /// 같은 검색어(정규화 기준)가 있으면 시간만 갱신하고, 최대 개수를 넘으면 오래된 것부터 지운다.
    func save(keyword: String, searchedAt: Date, maxCount: Int) async throws
    func delete(id: String) async throws
    func deleteAll() async throws
}
