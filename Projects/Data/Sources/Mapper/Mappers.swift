import Database
import Domain
import Foundation

// DTO / DB 레코드 → Domain Entity 변환.
// 서버가 비워서 보낼 수 있는 값(평점, 가격 등)의 기본값을 여기서 정한다.

extension AppSummaryDTO {
    func toDomain() -> AppSummary {
        AppSummary(
            id: id,
            name: name,
            sellerName: sellerName,
            iconURL: iconUrl.flatMap(URL.init(string:)),
            primaryGenre: primaryGenre,
            averageRating: averageRating ?? 0,
            ratingCount: ratingCount ?? 0,
            formattedPrice: formattedPrice ?? "무료"
        )
    }
}

extension AppDetailDTO {
    func toDomain() -> AppDetail {
        AppDetail(
            summary: AppSummary(
                id: id,
                name: name,
                sellerName: sellerName,
                iconURL: iconUrl.flatMap(URL.init(string:)),
                primaryGenre: primaryGenre,
                averageRating: averageRating ?? 0,
                ratingCount: ratingCount ?? 0,
                formattedPrice: formattedPrice ?? "무료"
            ),
            description: description,
            version: version,
            releaseNotes: releaseNotes?.isEmpty == true ? nil : releaseNotes,
            screenshotURLs: screenshotUrls.compactMap(URL.init(string:)),
            genres: genres,
            fileSizeBytes: fileSizeBytes,
            contentRating: contentRating ?? "-",
            minimumOSVersion: minimumOsVersion ?? "-",
            currentVersionReleaseDate: currentVersionReleaseDate,
            appStoreURL: trackViewUrl.flatMap(URL.init(string:))
        )
    }
}

extension PageDTO where Item == AppSummaryDTO {
    func toDomain() -> Page<AppSummary> {
        Page(items: items.map { $0.toDomain() }, total: total, offset: offset, limit: limit)
    }
}

extension ProfileDTO {
    func toDomain(baseURL: URL) -> Profile {
        Profile(
            name: name,
            email: email,
            // 서버는 "/media/avatars/1.jpg" 같은 상대 경로를 줄 수 있으므로 baseURL 기준으로 풀어 준다.
            // updatedAt을 쿼리로 붙여서 이미지를 바꿨을 때 Kingfisher 캐시가 갱신되게 한다.
            avatarURL: avatarUrl.flatMap { path in
                guard var components = URLComponents(
                    url: URL(string: path, relativeTo: baseURL)?.absoluteURL ?? baseURL,
                    resolvingAgainstBaseURL: true
                ) else { return nil }
                components.queryItems = [URLQueryItem(name: "v", value: String(Int(updatedAt.timeIntervalSince1970)))]
                return components.url
            }
        )
    }
}

// MARK: - DB 레코드

extension FavoriteAppRecord {
    func toDomain() -> FavoriteApp {
        FavoriteApp(
            id: id,
            name: name,
            sellerName: sellerName,
            iconURL: iconURL.flatMap(URL.init(string:)),
            primaryGenre: primaryGenre,
            averageRating: averageRating,
            addedAt: addedAt
        )
    }

    init(_ app: FavoriteApp) {
        self.init(
            id: app.id,
            name: app.name,
            sellerName: app.sellerName,
            iconURL: app.iconURL?.absoluteString,
            primaryGenre: app.primaryGenre,
            averageRating: app.averageRating,
            addedAt: app.addedAt
        )
    }
}

extension RecentKeywordRecord {
    func toDomain() -> RecentKeyword {
        RecentKeyword(id: id, keyword: keyword, searchedAt: searchedAt)
    }
}
