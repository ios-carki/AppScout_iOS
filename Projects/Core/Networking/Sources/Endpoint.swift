import Foundation

/// HTTP 메서드. Alamofire 타입을 모듈 밖으로 노출하지 않기 위해 따로 정의한다.
public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// 요청 하나를 설명하는 값.
///
/// 문자열로 URL을 이어 붙이면(`baseURL + "lookup=id=\(id)"`) 오타가 나도 컴파일러가 잡지 못한다.
/// 경로·쿼리·바디를 분리해서 선언하고, URL 조립과 인코딩은 `HTTPClient`가 맡는다.
public struct Endpoint: Sendable {
    public var path: String
    public var method: HTTPMethod
    public var queryItems: [URLQueryItem]
    public var body: (any Encodable & Sendable)?
    public var headers: [String: String]

    public init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        body: (any Encodable & Sendable)? = nil,
        headers: [String: String] = [:]
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.body = body
        self.headers = headers
    }

    /// baseURL과 합쳐서 최종 URL을 만든다. 쿼리 값의 퍼센트 인코딩은 URLComponents가 처리한다.
    public func url(baseURL: URL) throws(NetworkError) -> URL {
        let joined = baseURL.appendingPathComponent(path)
        guard var components = URLComponents(url: joined, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL(joined.absoluteString)
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw NetworkError.invalidURL(joined.absoluteString)
        }
        return url
    }
}

/// multipart/form-data로 올릴 파일
public struct MultipartFile: Sendable {
    public var fieldName: String
    public var fileName: String
    public var mimeType: String
    public var data: Data

    public init(fieldName: String, fileName: String, mimeType: String, data: Data) {
        self.fieldName = fieldName
        self.fileName = fileName
        self.mimeType = mimeType
        self.data = data
    }
}
