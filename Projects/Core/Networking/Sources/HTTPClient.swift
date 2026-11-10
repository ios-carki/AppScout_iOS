import Alamofire
import Foundation

/// 네트워킹의 루트. 서버의 도메인 규칙(어떤 API가 있는지)은 모르고, "요청을 보내고 응답을 디코딩"만 한다.
///
/// 프로토콜로 둔 이유: Data 모듈의 RepositoryImpl 테스트에서 가짜 클라이언트로 바꿔 끼우기 위함.
public protocol HTTPClient: Sendable {
    /// 응답 바디를 `T`로 디코딩해서 반환한다.
    func request<T: Decodable & Sendable>(_ endpoint: Endpoint, as type: T.Type) async throws(NetworkError) -> T

    /// 응답 바디가 필요 없는 요청 (204 No Content 등)
    func requestVoid(_ endpoint: Endpoint) async throws(NetworkError)

    /// multipart/form-data 업로드 후 응답을 `T`로 디코딩한다.
    func upload<T: Decodable & Sendable>(
        _ file: MultipartFile,
        to endpoint: Endpoint,
        as type: T.Type
    ) async throws(NetworkError) -> T
}

/// Alamofire 기반 구현
public final class AlamofireHTTPClient: HTTPClient {
    private let baseURL: URL
    private let session: Session
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    public init(
        baseURL: URL,
        configuration: URLSessionConfiguration = .default,
        enablesLogging: Bool = true
    ) {
        self.baseURL = baseURL
        configuration.timeoutIntervalForRequest = 15
        #if DEBUG
        let monitors: [EventMonitor] = enablesLogging ? [NetworkLogger()] : []
        #else
        let monitors: [EventMonitor] = []
        #endif
        self.session = Session(configuration: configuration, eventMonitors: monitors)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
    }

    public func request<T: Decodable & Sendable>(
        _ endpoint: Endpoint,
        as type: T.Type
    ) async throws(NetworkError) -> T {
        let urlRequest = try makeURLRequest(endpoint)
        let response = await session.request(urlRequest)
            .serializingData(emptyResponseCodes: [204, 205])
            .response
        return try decode(response, as: T.self)
    }

    public func requestVoid(_ endpoint: Endpoint) async throws(NetworkError) {
        let urlRequest = try makeURLRequest(endpoint)
        let response = await session.request(urlRequest)
            .serializingData(emptyResponseCodes: [200, 201, 204, 205])
            .response
        _ = try validate(response)
    }

    public func upload<T: Decodable & Sendable>(
        _ file: MultipartFile,
        to endpoint: Endpoint,
        as type: T.Type
    ) async throws(NetworkError) -> T {
        var urlRequest = try makeURLRequest(endpoint)
        // multipart 경계(boundary)가 들어간 Content-Type은 Alamofire가 직접 채운다.
        urlRequest.headers.remove(name: "Content-Type")
        let response = await session.upload(
            multipartFormData: { form in
                form.append(file.data, withName: file.fieldName, fileName: file.fileName, mimeType: file.mimeType)
            },
            with: urlRequest
        )
        .serializingData()
        .response
        return try decode(response, as: T.self)
    }

    // MARK: - Private

    private func makeURLRequest(_ endpoint: Endpoint) throws(NetworkError) -> URLRequest {
        let url = try endpoint.url(baseURL: baseURL)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        if let body = endpoint.body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw .encoding(underlying: error)
            }
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }

    /// 상태 코드를 확인하고 바디 데이터를 꺼낸다.
    private func validate(_ response: DataResponse<Data, AFError>) throws(NetworkError) -> Data {
        if let afError = response.error {
            if afError.isExplicitlyCancelledError { throw .cancelled }
            // 응답 자체가 없으면 연결 문제
            if response.response == nil { throw .transport(underlying: afError.underlyingError ?? afError) }
        }
        guard let http = response.response else {
            throw .transport(underlying: URLError(.badServerResponse))
        }
        let data = response.data ?? Data()
        guard (200..<300).contains(http.statusCode) else {
            let body = try? decoder.decode(ServerErrorBody.self, from: data)
            throw .server(statusCode: http.statusCode, body: body)
        }
        return data
    }

    private func decode<T: Decodable>(
        _ response: DataResponse<Data, AFError>,
        as type: T.Type
    ) throws(NetworkError) -> T {
        let data = try validate(response)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw .decoding(underlying: error, rawBody: String(data: data, encoding: .utf8))
        }
    }
}
