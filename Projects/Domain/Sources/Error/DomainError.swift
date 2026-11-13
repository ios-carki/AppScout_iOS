import Foundation

/// Feature 계층이 받는 유일한 에러 타입.
///
/// Data 계층은 네트워크·DB 에러를 이 타입으로 바꿔서 던진다.
/// Feature는 `error.message`를 알럿에 그대로 쓰면 되고, Alamofire나 SQLite 에러를 알 필요가 없다.
public enum DomainError: Error, Equatable, Sendable {
    /// 인터넷 연결 없음, 타임아웃 등
    case network
    /// 요청한 대상이 없음 (404)
    case notFound
    /// 입력값 검증 실패 (클라이언트 또는 서버 422)
    case validation(ValidationError)
    /// 서버 오류. 서버가 사용자용 메시지를 줬다면 함께 담는다.
    case server(message: String?)
    /// 로컬 DB 오류
    case storage
    /// 그 외. 디버깅용 설명을 담는다 (사용자에게 그대로 보여 주지 않음)
    case unknown(debugDescription: String)

    /// 사용자에게 보여 줄 메시지
    public var message: String {
        switch self {
        case .network:
            "네트워크 연결을 확인해 주세요."
        case .notFound:
            "요청한 정보를 찾을 수 없어요."
        case let .validation(error):
            error.message
        case let .server(message):
            message ?? "서버에 문제가 생겼어요. 잠시 후 다시 시도해 주세요."
        case .storage:
            "기기에 저장하지 못했어요. 저장 공간을 확인해 주세요."
        case .unknown:
            "알 수 없는 문제가 발생했어요."
        }
    }
}

extension Error {
    /// 사용자에게 보여 줄 메시지.
    ///
    /// `DomainError`면 그 메시지를, 아니면 `DomainError.unknown`의 메시지를 쓴다.
    /// Feature의 `catch`에서 `error.userMessage`로 바로 꺼내 쓰면 된다.
    public var userMessage: String {
        (self as? DomainError ?? .unknown(debugDescription: String(describing: self))).message
    }
}

/// 입력값 검증 실패 사유
public enum ValidationError: Error, Equatable, Sendable {
    case nameTooShort(minimum: Int)
    case nameTooLong(maximum: Int)
    case emailEmpty
    case emailInvalid
    case emailTooLong(maximum: Int)
    case imageEmpty
    case imageTooLarge(maximumMegabytes: Int)
    /// 서버가 내려준 검증 메시지
    case server(message: String)

    public var message: String {
        switch self {
        case let .nameTooShort(minimum):
            "이름은 \(minimum)자 이상 입력해 주세요."
        case let .nameTooLong(maximum):
            "이름은 \(maximum)자 이하로 입력해 주세요."
        case .emailEmpty:
            "이메일을 입력해 주세요."
        case .emailInvalid:
            "이메일 형식이 올바르지 않아요."
        case let .emailTooLong(maximum):
            "이메일은 \(maximum)자 이하로 입력해 주세요."
        case .imageEmpty:
            "이미지를 선택해 주세요."
        case let .imageTooLarge(maximumMegabytes):
            "이미지는 \(maximumMegabytes)MB 이하만 올릴 수 있어요."
        case let .server(message):
            message
        }
    }
}
