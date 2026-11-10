import Foundation

/// 서버가 내려주는 공통 에러 바디: `{ "code": "...", "message": "..." }`
public struct ServerErrorBody: Decodable, Equatable, Sendable {
    public let code: String
    public let message: String

    public init(code: String, message: String) {
        self.code = code
        self.message = message
    }
}

/// 네트워크 계층 에러.
///
/// 강의 코드의 `NetworkError`는 원인 에러를 버리고 `.failToDecode` 같은 결과만 남겨서,
/// 어떤 키가 문제인지 알 수 없었다. 여기서는 원인(`underlying`)을 항상 함께 보관한다.
public enum NetworkError: Error, Sendable {
    /// URL 조립 실패
    case invalidURL(String)
    /// 연결 실패, 타임아웃 등 응답을 받지 못함
    case transport(underlying: any Error)
    /// 2xx가 아닌 응답. 서버가 공통 에러 바디를 줬다면 함께 담는다.
    case server(statusCode: Int, body: ServerErrorBody?)
    /// 응답은 받았지만 디코딩 실패
    case decoding(underlying: any Error, rawBody: String?)
    /// 요청 바디 인코딩 실패
    case encoding(underlying: any Error)
    /// Task 취소
    case cancelled

    public var statusCode: Int? {
        if case let .server(statusCode, _) = self { return statusCode }
        return nil
    }
}

extension NetworkError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .invalidURL(url):
            "NetworkError.invalidURL(\(url))"
        case let .transport(error):
            "NetworkError.transport(\(error))"
        case let .server(code, body):
            "NetworkError.server(\(code), \(body.map { "\($0.code): \($0.message)" } ?? "no body"))"
        case let .decoding(error, raw):
            "NetworkError.decoding(\(error))\nraw: \(raw?.prefix(500) ?? "nil")"
        case let .encoding(error):
            "NetworkError.encoding(\(error))"
        case .cancelled:
            "NetworkError.cancelled"
        }
    }
}
