import Foundation

// 서버 응답 형태 그대로의 타입(DTO).
// - 키는 서버가 snake_case로 주고, HTTPClient의 디코더가 camelCase로 바꾼다. ("icon_url" → iconUrl)
// - 화면에서 쓰는 Entity와 분리해 두면, 서버 응답이 바뀌어도 Mapper만 고치면 된다.

struct PageDTO<Item: Decodable & Sendable>: Decodable, Sendable {
    let total: Int
    let limit: Int
    let offset: Int
    let items: [Item]
}

struct AppSummaryDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let sellerName: String
    let iconUrl: String?
    let primaryGenre: String
    let averageRating: Double?
    let ratingCount: Int?
    let formattedPrice: String?
}

struct AppDetailDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let sellerName: String
    let iconUrl: String?
    let primaryGenre: String
    let averageRating: Double?
    let ratingCount: Int?
    let formattedPrice: String?
    let description: String
    let version: String
    let releaseNotes: String?
    let screenshotUrls: [String]
    let genres: [String]
    let fileSizeBytes: Int64?
    let contentRating: String?
    let minimumOsVersion: String?
    let currentVersionReleaseDate: Date?
    let trackViewUrl: String?
}

struct ProfileDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let email: String
    let avatarUrl: String?
    let updatedAt: Date
}

/// PATCH /v1/users/me 요청 바디. nil인 필드는 JSON에서 빠진다(= 변경하지 않음).
struct UpdateProfileRequestDTO: Encodable, Sendable {
    let name: String?
    let email: String?
}
