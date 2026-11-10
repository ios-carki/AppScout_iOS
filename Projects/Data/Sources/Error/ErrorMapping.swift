import Domain
import Foundation
import Networking

/// 네트워크 에러 → 화면에서 쓰는 DomainError
extension NetworkError {
    var asDomainError: any Error {
        switch self {
        case .cancelled:
            // TCA Effect 취소는 CancellationError로 전달해야 알럿 없이 조용히 끝난다.
            return CancellationError()
        case .transport:
            return DomainError.network
        case let .server(statusCode, body):
            switch statusCode {
            case 404:
                return DomainError.notFound
            case 400, 413, 415, 422:
                return DomainError.validation(.server(message: body?.message ?? "입력값을 확인해 주세요."))
            default:
                return DomainError.server(message: body?.message)
            }
        case .invalidURL, .decoding, .encoding:
            return DomainError.unknown(debugDescription: debugDescription)
        }
    }
}

/// RepositoryImpl 안에서 원격 호출을 감싸서 에러를 DomainError로 바꾼다.
func mapNetworkError<T>(_ operation: () async throws(NetworkError) -> T) async throws -> T {
    do {
        return try await operation()
    } catch {
        throw error.asDomainError
    }
}

/// RepositoryImpl 안에서 DB 작업을 감싸서 에러를 DomainError.storage로 바꾼다.
func mapStorageError<T>(_ operation: () async throws -> T) async throws -> T {
    do {
        return try await operation()
    } catch is CancellationError {
        throw CancellationError()
    } catch {
        throw DomainError.storage
    }
}
