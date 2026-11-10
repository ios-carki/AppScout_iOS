import Foundation

/// 프로필 입력 규칙.
///
/// 서버(`Server/app/schemas.py`)도 같은 규칙으로 한 번 더 검증한다.
/// 클라이언트에서 먼저 검사하는 이유: 불필요한 요청을 줄이고 즉시 피드백을 주기 위함.
public enum ProfileValidator {
    public static let nameLength = 2...20
    public static let emailMaxLength = 100
    public static let imageMaxBytes = 5 * 1024 * 1024

    /// 검증을 통과하면 앞뒤 공백을 제거한 이름을 돌려준다.
    public static func validateName(_ name: String) throws(ValidationError) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count < nameLength.lowerBound {
            throw .nameTooShort(minimum: nameLength.lowerBound)
        }
        if trimmed.count > nameLength.upperBound {
            throw .nameTooLong(maximum: nameLength.upperBound)
        }
        return trimmed
    }

    /// 검증을 통과하면 앞뒤 공백을 제거한 이메일을 돌려준다.
    public static func validateEmail(_ email: String) throws(ValidationError) -> String {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { throw .emailEmpty }
        if trimmed.count > emailMaxLength { throw .emailTooLong(maximum: emailMaxLength) }
        let pattern = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        if trimmed.range(of: pattern, options: .regularExpression) == nil {
            throw .emailInvalid
        }
        return trimmed
    }

    public static func validateImage(_ data: Data) throws(ValidationError) {
        if data.isEmpty { throw .imageEmpty }
        if data.count > imageMaxBytes {
            throw .imageTooLarge(maximumMegabytes: imageMaxBytes / 1024 / 1024)
        }
    }
}
