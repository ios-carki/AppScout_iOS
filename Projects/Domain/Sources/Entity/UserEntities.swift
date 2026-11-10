import Foundation

/// 사용자 프로필 (서버에 저장)
public struct Profile: Equatable, Sendable {
    public let name: String
    public let email: String
    public let avatarURL: URL?

    public init(name: String, email: String, avatarURL: URL?) {
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
    }
}

/// 최근 검색어 (로컬 DB에 저장)
public struct RecentKeyword: Equatable, Hashable, Identifiable, Sendable {
    /// 정규화된 검색어 (앞뒤 공백 제거 + 소문자). 중복 판별 기준
    public let id: String
    /// 사용자가 입력한 원래 검색어
    public let keyword: String
    public let searchedAt: Date

    public init(id: String, keyword: String, searchedAt: Date) {
        self.id = id
        self.keyword = keyword
        self.searchedAt = searchedAt
    }

    /// "  Kakao " → "kakao"
    public static func normalize(_ keyword: String) -> String {
        keyword.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

/// 즐겨찾기한 앱 (로컬 DB에 저장되는 목록용 스냅샷)
public struct FavoriteApp: Equatable, Hashable, Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let sellerName: String
    public let iconURL: URL?
    public let primaryGenre: String
    public let averageRating: Double
    public let addedAt: Date

    public init(
        id: Int,
        name: String,
        sellerName: String,
        iconURL: URL?,
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

    /// 상세 화면의 즐겨찾기 버튼에서 사용
    public init(_ summary: AppSummary, addedAt: Date) {
        self.init(
            id: summary.id,
            name: summary.name,
            sellerName: summary.sellerName,
            iconURL: summary.iconURL,
            primaryGenre: summary.primaryGenre,
            averageRating: summary.averageRating,
            addedAt: addedAt
        )
    }
}
