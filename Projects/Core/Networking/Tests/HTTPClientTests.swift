import Foundation
import Testing
@testable import Networking

/// URLProtocol로 실제 네트워크 없이 응답을 흉내 낸다.
final class StubURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var handler: ((URLRequest) -> (Int, Data))?
    nonisolated(unsafe) static var lastRequest: URLRequest?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.lastRequest = request
        let (status, data) = Self.handler?(request) ?? (500, Data())
        let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

private struct Item: Decodable, Equatable, Sendable {
    let trackName: String
    let averageUserRating: Double
}

@Suite("HTTPClient", .serialized)
struct HTTPClientTests {
    let client: AlamofireHTTPClient

    init() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        client = AlamofireHTTPClient(
            baseURL: URL(string: "http://localhost:8000")!,
            configuration: config,
            enablesLogging: false
        )
    }

    @Test("snake_case 응답을 camelCase 프로퍼티로 디코딩한다")
    func decodesSnakeCase() async throws {
        StubURLProtocol.handler = { _ in
            (200, #"{"track_name":"카카오톡","average_user_rating":4.5}"#.data(using: .utf8)!)
        }
        let item = try await client.request(Endpoint(path: "/v1/apps/1"), as: Item.self)
        #expect(item == Item(trackName: "카카오톡", averageUserRating: 4.5))
    }

    @Test("쿼리 값(한글, 공백, &)은 퍼센트 인코딩된다")
    func encodesQuery() async throws {
        StubURLProtocol.handler = { _ in (200, #"{"track_name":"a","average_user_rating":1}"#.data(using: .utf8)!) }
        _ = try await client.request(
            Endpoint(path: "/v1/apps/search", queryItems: [URLQueryItem(name: "term", value: "카카오 & 톡")]),
            as: Item.self
        )
        let url = try #require(StubURLProtocol.lastRequest?.url)
        let term = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?.first { $0.name == "term" }?.value
        #expect(url.path == "/v1/apps/search")
        #expect(term == "카카오 & 톡")
    }

    @Test("2xx가 아니면 서버 에러 바디와 함께 server 에러를 던진다")
    func serverError() async {
        StubURLProtocol.handler = { _ in
            (422, #"{"code":"invalid_email","message":"이메일 형식이 올바르지 않아요."}"#.data(using: .utf8)!)
        }
        do {
            _ = try await client.request(Endpoint(path: "/v1/users/me", method: .patch), as: Item.self)
            Issue.record("에러가 나야 함")
        } catch {
            guard case let .server(status, body) = error else {
                Issue.record("server 에러가 아님: \(error)")
                return
            }
            #expect(status == 422)
            #expect(body?.code == "invalid_email")
        }
    }

    @Test("디코딩 실패 시 원인 에러와 원본 바디를 보존한다")
    func decodingErrorKeepsCause() async {
        StubURLProtocol.handler = { _ in (200, #"{"wrong":"shape"}"#.data(using: .utf8)!) }
        do {
            _ = try await client.request(Endpoint(path: "/v1/apps/1"), as: Item.self)
            Issue.record("에러가 나야 함")
        } catch {
            guard case let .decoding(underlying, raw) = error else {
                Issue.record("decoding 에러가 아님: \(error)")
                return
            }
            #expect(underlying is DecodingError)
            #expect(raw == #"{"wrong":"shape"}"#)
        }
    }
}
