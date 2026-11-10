import Database
import Domain
import Foundation
import Networking
import Testing
@testable import Data

// MARK: - 테스트 도우미

/// Tests/Resources의 JSON 파일을 읽는다.
private func fixture(_ name: String) throws -> Data {
    let bundle = Bundle(for: BundleToken.self)
    let url = try #require(bundle.url(forResource: name, withExtension: "json"))
    return try Data(contentsOf: url)
}

private final class BundleToken {}

/// 네트워크 대신 정해진 응답(픽스처 또는 에러)을 돌려주는 HTTPClient
private final class FakeHTTPClient: HTTPClient, @unchecked Sendable {
    enum Response {
        case json(Data)
        case failure(NetworkError)
    }

    var response: Response
    private(set) var requestedPaths: [String] = []

    init(_ response: Response) {
        self.response = response
    }

    private func decode<T: Decodable>(_ type: T.Type) throws(NetworkError) -> T {
        switch response {
        case let .failure(error):
            throw error
        case let .json(data):
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            do { return try decoder.decode(T.self, from: data) } catch {
                throw .decoding(underlying: error, rawBody: nil)
            }
        }
    }

    func request<T: Decodable & Sendable>(_ endpoint: Endpoint, as type: T.Type) async throws(NetworkError) -> T {
        requestedPaths.append(endpoint.path)
        return try decode(T.self)
    }

    func requestVoid(_ endpoint: Endpoint) async throws(NetworkError) {
        requestedPaths.append(endpoint.path)
    }

    func upload<T: Decodable & Sendable>(
        _ file: MultipartFile, to endpoint: Endpoint, as type: T.Type
    ) async throws(NetworkError) -> T {
        requestedPaths.append(endpoint.path)
        return try decode(T.self)
    }
}

// MARK: - 원격 Repository

@Suite("AppRepositoryImpl")
struct AppRepositoryTests {
    @Test("검색 응답을 Entity로 바꾸고, 비어 있는 값은 기본값으로 채운다")
    func search() async throws {
        let client = FakeHTTPClient(.json(try fixture("search_response")))
        let page = try await AppRepositoryImpl(client: client).searchApps(term: "kakao", page: .first)

        #expect(client.requestedPaths == ["/v1/apps/search"])
        #expect(page.total == 2)
        #expect(page.hasNext == false)
        #expect(page.items[0].name == "카카오톡 KakaoTalk")
        #expect(page.items[0].iconURL?.host() == "is1-ssl.mzstatic.com")
        // null 필드 기본값
        #expect(page.items[1].averageRating == 0)
        #expect(page.items[1].formattedPrice == "무료")
    }

    @Test("상세 응답: 날짜 파싱, 빈 릴리스 노트는 nil, 스크린샷 URL 변환")
    func detail() async throws {
        let client = FakeHTTPClient(.json(try fixture("detail_response")))
        let detail = try await AppRepositoryImpl(client: client).fetchAppDetail(id: 362_057_947)

        #expect(detail.id == 362_057_947)
        #expect(detail.screenshotURLs.count == 2)
        #expect(detail.releaseNotes == nil)
        #expect(detail.currentVersionReleaseDate == ISO8601DateFormatter().date(from: "2025-10-01T09:00:00Z"))
        #expect(detail.appStoreURL?.absoluteString == "https://apps.apple.com/kr/app/id362057947")
    }

    @Test("네트워크 에러를 DomainError로 바꾼다", arguments: [
        (NetworkError.transport(underlying: URLError(.notConnectedToInternet)), DomainError.network),
        (NetworkError.server(statusCode: 404, body: nil), DomainError.notFound),
        (
            NetworkError.server(statusCode: 500, body: ServerErrorBody(code: "internal", message: "점검 중이에요.")),
            DomainError.server(message: "점검 중이에요.")
        ),
    ])
    func errorMapping(networkError: NetworkError, expected: DomainError) async {
        let repository = AppRepositoryImpl(client: FakeHTTPClient(.failure(networkError)))
        await #expect(throws: expected) {
            try await repository.fetchAppDetail(id: 1)
        }
    }

    @Test("요청이 취소되면 CancellationError로 전달한다 (알럿을 띄우지 않기 위함)")
    func cancellation() async {
        let repository = AppRepositoryImpl(client: FakeHTTPClient(.failure(.cancelled)))
        await #expect(throws: CancellationError.self) {
            try await repository.fetchAppDetail(id: 1)
        }
    }
}

@Suite("ProfileRepositoryImpl")
struct ProfileRepositoryTests {
    @Test("상대 경로 아바타를 baseURL 기준 절대 URL로 바꾸고 캐시 무효화 쿼리를 붙인다")
    func avatarURL() async throws {
        let client = FakeHTTPClient(.json(try fixture("profile_response")))
        let repository = ProfileRepositoryImpl(client: client, baseURL: URL(string: "http://localhost:8000")!)
        let profile = try await repository.fetchProfile()

        #expect(profile.avatarURL?.absoluteString.hasPrefix("http://localhost:8000/media/avatars/1.jpg?v=") == true)
    }

    @Test("422 응답은 서버 메시지를 담은 validation 에러가 된다")
    func validationError() async {
        let client = FakeHTTPClient(.failure(.server(
            statusCode: 422,
            body: ServerErrorBody(code: "invalid_email", message: "이메일 형식이 올바르지 않아요.")
        )))
        let repository = ProfileRepositoryImpl(client: client, baseURL: URL(string: "http://localhost:8000")!)
        await #expect(throws: DomainError.validation(.server(message: "이메일 형식이 올바르지 않아요."))) {
            try await repository.updateProfile(name: nil, email: "wrong")
        }
    }

    @Test("이미지로 읽을 수 없는 데이터는 업로드하지 않는다")
    func invalidImage() async {
        let client = FakeHTTPClient(.json(Data()))
        let repository = ProfileRepositoryImpl(client: client, baseURL: URL(string: "http://localhost:8000")!)
        await #expect(throws: DomainError.self) {
            try await repository.uploadAvatar(imageData: Data("not an image".utf8))
        }
        #expect(client.requestedPaths.isEmpty)
    }
}

// MARK: - 로컬 Repository

@Suite("Local repositories")
struct LocalRepositoryTests {
    let database: any DatabaseWriter

    init() throws {
        database = try inMemoryAppDatabase()
    }

    @Test("최근 검색어: 대소문자·공백이 달라도 같은 검색어로 보고, 최대 개수를 넘으면 오래된 것부터 지운다")
    func recentKeywords() async throws {
        let repository = RecentKeywordRepositoryImpl(database: database)
        for (index, word) in ["a1", "a2", "a3", "A1 "].enumerated() {
            try await repository.save(
                keyword: word,
                searchedAt: Date(timeIntervalSince1970: Double(index)),
                maxCount: 2
            )
        }
        var iterator = repository.observeRecentKeywords(limit: 10).makeAsyncIterator()
        let keywords = try #require(try await iterator.next())

        // "A1 "이 가장 최근, 그다음 a3. a2는 개수 초과로 삭제
        #expect(keywords.map(\.id) == ["a1", "a3"])
        #expect(keywords.first?.keyword == "A1 ")
    }

    @Test("즐겨찾기: 추가하면 관찰 스트림에 새 목록이 방출된다")
    func favoritesObservation() async throws {
        let repository = FavoriteRepositoryImpl(database: database)
        var iterator = repository.observeFavorites().makeAsyncIterator()

        let initial = try #require(try await iterator.next())
        #expect(initial.isEmpty)

        try await repository.add(FavoriteApp(.mock, addedAt: Date(timeIntervalSince1970: 10)))
        let updated = try #require(try await iterator.next())
        #expect(updated.map(\.id) == [AppSummary.mock.id])
        #expect(try await repository.isFavorite(appID: AppSummary.mock.id))

        try await repository.remove(appID: AppSummary.mock.id)
        #expect(try await repository.isFavorite(appID: AppSummary.mock.id) == false)
    }
}
