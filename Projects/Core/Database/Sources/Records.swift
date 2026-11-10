import Foundation
import SQLiteData

/// 최근 검색어 테이블.
///
/// - `id`: 중복 판별용으로 정규화한 검색어(앞뒤 공백 제거 + 소문자). "Kakao"와 "kakao "는 같은 검색어.
/// - `keyword`: 화면에 보여 줄 원래 입력값
@Table("recentKeywords")
public struct RecentKeywordRecord: Equatable, Identifiable, Sendable {
    public let id: String
    public var keyword: String
    public var searchedAt: Date

    public init(id: String, keyword: String, searchedAt: Date) {
        self.id = id
        self.keyword = keyword
        self.searchedAt = searchedAt
    }
}

/// 즐겨찾기 테이블.
///
/// 상세 정보 전체가 아니라 목록 표시에 필요한 값만 스냅샷으로 저장한다.
/// (오프라인에서도 즐겨찾기 탭을 그릴 수 있고, 최신 정보는 상세 진입 시 서버에서 받는다)
@Table("favoriteApps")
public struct FavoriteAppRecord: Equatable, Identifiable, Sendable {
    /// 서버 앱 ID (iTunes trackId)
    public let id: Int
    public var name: String
    public var sellerName: String
    public var iconURL: String?
    public var primaryGenre: String
    public var averageRating: Double
    public var addedAt: Date

    public init(
        id: Int,
        name: String,
        sellerName: String,
        iconURL: String?,
        primaryGenre: String,
        averageRating: Double,
        addedAt: Date
    ) {
        self.id = id
        self.name = name
        self.sellerName = sellerName
        self.iconURL = iconURL
        self.primaryGenre = primaryGenre
        self.averageRating = averageRating
        self.addedAt = addedAt
    }
}
