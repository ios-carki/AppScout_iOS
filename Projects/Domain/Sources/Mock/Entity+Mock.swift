import Foundation

// 프리뷰와 테스트에서 쓰는 샘플 데이터.
// 실제 아이콘 URL은 서버 시드 데이터(iTunes)에서 가져온 것과 같은 형식이지만, 네트워크 없이도 동작하도록 nil을 허용한다.

extension AppSummary {
    public static let mock = AppSummary(
        id: 362_057_947,
        name: "카카오톡 KakaoTalk",
        sellerName: "Kakao Corp.",
        iconURL: nil,
        primaryGenre: "소셜 네트워킹",
        averageRating: 3.4,
        ratingCount: 152_381,
        formattedPrice: "무료"
    )

    public static let mocks: [AppSummary] = [
        mock,
        AppSummary(id: 1, name: "토스", sellerName: "Viva Republica", iconURL: nil,
                   primaryGenre: "금융", averageRating: 4.8, ratingCount: 1_203_441, formattedPrice: "무료"),
        AppSummary(id: 2, name: "네이버 지도", sellerName: "NAVER Corp.", iconURL: nil,
                   primaryGenre: "내비게이션", averageRating: 4.6, ratingCount: 412_090, formattedPrice: "무료"),
        AppSummary(id: 3, name: "Things 3", sellerName: "Cultured Code", iconURL: nil,
                   primaryGenre: "생산성", averageRating: 4.7, ratingCount: 3_211, formattedPrice: "₩14,000"),
        AppSummary(id: 4, name: "배달의민족", sellerName: "Woowa Brothers", iconURL: nil,
                   primaryGenre: "음식 및 음료", averageRating: 4.7, ratingCount: 821_002, formattedPrice: "무료"),
        AppSummary(id: 5, name: "Notion", sellerName: "Notion Labs", iconURL: nil,
                   primaryGenre: "생산성", averageRating: 4.5, ratingCount: 9_870, formattedPrice: "무료"),
    ]
}

extension AppDetail {
    public static func mock(summary: AppSummary = .mock) -> AppDetail {
        AppDetail(
            summary: summary,
            description: "\(summary.name)의 설명입니다.\n여러 줄로 된 긴 설명이 들어갑니다. 상세 화면에서는 3줄까지 보여 주고 '더 보기'로 펼칩니다.",
            version: "10.2.1",
            releaseNotes: "- 버그 수정\n- 성능 개선",
            screenshotURLs: [],
            genres: [summary.primaryGenre, "엔터테인먼트"],
            fileSizeBytes: 312_000_000,
            contentRating: "4+",
            minimumOSVersion: "16.0",
            currentVersionReleaseDate: Date(timeIntervalSince1970: 1_760_000_000),
            appStoreURL: URL(string: "https://apps.apple.com/kr/app/id\(summary.id)")
        )
    }
}

extension FavoriteApp {
    public static let mocks: [FavoriteApp] = AppSummary.mocks.enumerated().map { index, app in
        FavoriteApp(app, addedAt: Date(timeIntervalSince1970: 1_760_000_000 - Double(index) * 3_600))
    }
}

extension RecentKeyword {
    public static let mocks: [RecentKeyword] = ["카카오", "토스", "노션", "지도"].enumerated().map { index, word in
        RecentKeyword(
            id: RecentKeyword.normalize(word),
            keyword: word,
            searchedAt: Date(timeIntervalSince1970: 1_760_000_000 - Double(index) * 60)
        )
    }
}

extension Profile {
    public static let mock = Profile(name: "Chris", email: "chris@example.com", avatarURL: nil)
}
