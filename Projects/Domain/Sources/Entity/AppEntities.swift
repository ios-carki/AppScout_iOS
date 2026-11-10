import Foundation

/// 검색 결과 목록의 앱 한 개
public struct AppSummary: Equatable, Hashable, Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let sellerName: String
    public let iconURL: URL?
    public let primaryGenre: String
    public let averageRating: Double
    public let ratingCount: Int
    /// 서버가 현지화해서 내려준 가격 문자열 ("무료", "₩4,400")
    public let formattedPrice: String

    public init(
        id: Int,
        name: String,
        sellerName: String,
        iconURL: URL?,
        primaryGenre: String,
        averageRating: Double,
        ratingCount: Int,
        formattedPrice: String
    ) {
        self.id = id
        self.name = name
        self.sellerName = sellerName
        self.iconURL = iconURL
        self.primaryGenre = primaryGenre
        self.averageRating = averageRating
        self.ratingCount = ratingCount
        self.formattedPrice = formattedPrice
    }
}

/// 앱 상세 정보
public struct AppDetail: Equatable, Identifiable, Sendable {
    public let summary: AppSummary
    public let description: String
    public let version: String
    public let releaseNotes: String?
    public let screenshotURLs: [URL]
    public let genres: [String]
    public let fileSizeBytes: Int64?
    public let contentRating: String
    public let minimumOSVersion: String
    public let currentVersionReleaseDate: Date?
    /// App Store 페이지 주소 (공유, "App Store에서 보기"에 사용)
    public let appStoreURL: URL?

    public var id: Int { summary.id }

    public init(
        summary: AppSummary,
        description: String,
        version: String,
        releaseNotes: String?,
        screenshotURLs: [URL],
        genres: [String],
        fileSizeBytes: Int64?,
        contentRating: String,
        minimumOSVersion: String,
        currentVersionReleaseDate: Date?,
        appStoreURL: URL?
    ) {
        self.summary = summary
        self.description = description
        self.version = version
        self.releaseNotes = releaseNotes
        self.screenshotURLs = screenshotURLs
        self.genres = genres
        self.fileSizeBytes = fileSizeBytes
        self.contentRating = contentRating
        self.minimumOSVersion = minimumOSVersion
        self.currentVersionReleaseDate = currentVersionReleaseDate
        self.appStoreURL = appStoreURL
    }
}

/// 페이지네이션 요청
public struct PageRequest: Equatable, Hashable, Sendable {
    public static let defaultLimit = 20
    public static let first = PageRequest(offset: 0, limit: defaultLimit)

    public let offset: Int
    public let limit: Int

    public init(offset: Int, limit: Int = PageRequest.defaultLimit) {
        self.offset = max(0, offset)
        self.limit = min(max(1, limit), 50)
    }
}

/// 페이지네이션 응답
public struct Page<Item: Equatable & Sendable>: Equatable, Sendable {
    public let items: [Item]
    public let total: Int
    public let offset: Int
    public let limit: Int

    public init(items: [Item], total: Int, offset: Int, limit: Int) {
        self.items = items
        self.total = total
        self.offset = offset
        self.limit = limit
    }

    public static func empty(_ request: PageRequest = .first) -> Page {
        Page(items: [], total: 0, offset: request.offset, limit: request.limit)
    }

    /// 다음 페이지가 남아 있는지
    public var hasNext: Bool { offset + items.count < total }

    /// 다음 페이지 요청 (없으면 nil)
    public var nextRequest: PageRequest? {
        hasNext ? PageRequest(offset: offset + items.count, limit: limit) : nil
    }
}
