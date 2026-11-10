import Dependencies
import DependenciesMacros
import Foundation

/// 프로필 조회·수정.
///
/// 입력 검증(`ProfileValidator`)을 UseCase에서 먼저 하므로, 잘못된 값이면 서버에 요청하지 않고
/// `DomainError.validation`을 던진다. (강의 코드는 View에서 `guard !name.isEmpty`로 검증했음)
@DependencyClient
public struct ProfileUseCase: Sendable {
    public var fetch: @Sendable () async throws -> Profile
    public var updateName: @Sendable (_ name: String) async throws -> Profile
    public var updateEmail: @Sendable (_ email: String) async throws -> Profile
    /// JPEG/PNG 데이터. 5MB 이하만 허용한다.
    public var updateAvatar: @Sendable (_ imageData: Data) async throws -> Profile
}

extension ProfileUseCase {
    public static func live(repository: any ProfileRepository) -> Self {
        Self(
            fetch: { try await repository.fetchProfile() },
            updateName: { name in
                let valid = try validated { () throws(ValidationError) in try ProfileValidator.validateName(name) }
                return try await repository.updateProfile(name: valid, email: nil)
            },
            updateEmail: { email in
                let valid = try validated { () throws(ValidationError) in try ProfileValidator.validateEmail(email) }
                return try await repository.updateProfile(name: nil, email: valid)
            },
            updateAvatar: { data in
                try validated { () throws(ValidationError) in try ProfileValidator.validateImage(data) }
                return try await repository.uploadAvatar(imageData: data)
            }
        )
    }

    /// ValidationError를 DomainError.validation으로 감싼다.
    private static func validated<T>(_ body: () throws(ValidationError) -> T) throws(DomainError) -> T {
        do {
            return try body()
        } catch {
            throw .validation(error)
        }
    }
}

extension ProfileUseCase: TestDependencyKey {
    public static let testValue = Self()
    public static let previewValue: Self = {
        let profile = LockIsolated(Profile.mock)
        return Self(
            fetch: { profile.value },
            updateName: { name in
                profile.withValue { $0 = Profile(name: name, email: $0.email, avatarURL: $0.avatarURL) }
                return profile.value
            },
            updateEmail: { email in
                profile.withValue { $0 = Profile(name: $0.name, email: email, avatarURL: $0.avatarURL) }
                return profile.value
            },
            updateAvatar: { _ in profile.value }
        )
    }()
}

extension DependencyValues {
    public var profileUseCase: ProfileUseCase {
        get { self[ProfileUseCase.self] }
        set { self[ProfileUseCase.self] = newValue }
    }
}
