import Domain
import Foundation
import Networking
import Testing
@testable import Data

/// 로컬 FastAPI 서버(docker compose)에 실제로 요청해서 DTO·Mapper가 서버 응답과 맞는지 확인한다.
///
/// 서버가 필요해서 기본으로는 건너뛴다. 실행 방법:
/// ```
/// cd Server && docker compose up -d
/// TEST_RUNNER_APPSCOUT_INTEGRATION=1 xcodebuild test -workspace AppScout.xcworkspace -scheme Data \
///   -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
/// ```
@Suite(
    "Live server integration",
    .enabled(if: ProcessInfo.processInfo.environment["APPSCOUT_INTEGRATION"] == "1")
)
struct LiveServerIntegrationTests {
    let baseURL = URL(string: "http://localhost:8000")!
    var client: AlamofireHTTPClient { AlamofireHTTPClient(baseURL: baseURL, enablesLogging: false) }

    @Test("검색 → 다음 페이지 → 상세까지 실제 응답을 디코딩한다")
    func searchAndDetail() async throws {
        let repository = AppRepositoryImpl(client: client)

        let first = try await repository.searchApps(term: "카카오", page: PageRequest(offset: 0, limit: 3))
        #expect(first.items.count == 3)
        #expect(first.total >= 3)

        if let next = first.nextRequest {
            let second = try await repository.searchApps(term: "카카오", page: next)
            #expect(Set(first.items.map(\.id)).isDisjoint(with: second.items.map(\.id)))
        }

        let detail = try await repository.fetchAppDetail(id: first.items[0].id)
        #expect(detail.id == first.items[0].id)
        #expect(detail.currentVersionReleaseDate != nil)
        #expect(!detail.genres.isEmpty)
    }

    @Test("없는 앱은 notFound, 잘못된 이메일은 validation 에러")
    func errors() async throws {
        await #expect(throws: DomainError.notFound) {
            try await AppRepositoryImpl(client: client).fetchAppDetail(id: 1)
        }
        let profileRepository = ProfileRepositoryImpl(client: client, baseURL: baseURL)
        await #expect(throws: DomainError.validation(.server(message: "이메일 형식이 올바르지 않아요."))) {
            try await profileRepository.updateProfile(name: nil, email: "chris@")
        }
    }

    @Test("아바타 업로드: 압축된 JPEG가 올라가고 절대 URL로 돌아온다")
    func avatarUpload() async throws {
        // 2x2 PNG
        let png = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAFklEQVR4nGP8z8DAwMDAxMDAwMDAAAANHQEDasKb6QAAAABJRU5ErkJggg==")!
        let profile = try await ProfileRepositoryImpl(client: client, baseURL: baseURL).uploadAvatar(imageData: png)
        let url = try #require(profile.avatarURL)
        #expect(url.absoluteString.hasPrefix("http://localhost:8000/media/avatars/1.jpg?v="))

        let (data, response) = try await URLSession.shared.data(from: url)
        #expect((response as? HTTPURLResponse)?.statusCode == 200)
        #expect(data.starts(with: [0xFF, 0xD8]))  // JPEG 시그니처
    }
}
