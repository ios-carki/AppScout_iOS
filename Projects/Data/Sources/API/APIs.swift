import Domain
import Foundation
import Networking

// 서버 API 목록. 경로·쿼리를 문자열 하나로 이어 붙이지 않고 Endpoint로 선언한다.
// 명세: docs/backend.md

enum AppAPI {
    /// GET /v1/apps/search?term=&limit=&offset=
    static func search(term: String, page: PageRequest) -> Endpoint {
        Endpoint(
            path: "/v1/apps/search",
            queryItems: [
                URLQueryItem(name: "term", value: term),
                URLQueryItem(name: "limit", value: String(page.limit)),
                URLQueryItem(name: "offset", value: String(page.offset)),
            ]
        )
    }

    /// GET /v1/apps/{id}
    static func detail(id: Int) -> Endpoint {
        Endpoint(path: "/v1/apps/\(id)")
    }
}

enum ProfileAPI {
    /// GET /v1/users/me
    static let me = Endpoint(path: "/v1/users/me")

    /// PATCH /v1/users/me
    static func update(_ body: UpdateProfileRequestDTO) -> Endpoint {
        Endpoint(path: "/v1/users/me", method: .patch, body: body)
    }

    /// PUT /v1/users/me/avatar (multipart, field: "file")
    static let uploadAvatar = Endpoint(path: "/v1/users/me/avatar", method: .put)
}
