import Dependencies
import Foundation
import Testing
@testable import Domain

// MARK: - 가짜 Repository

private final class FakeAppRepository: AppRepository, @unchecked Sendable {
    var searchedTerms: [String] = []

    func searchApps(term: String, page: PageRequest) async throws -> Page<AppSummary> {
        searchedTerms.append(term)
        return Page(items: [.mock], total: 1, offset: page.offset, limit: page.limit)
    }

    func fetchAppDetail(id: Int) async throws -> AppDetail { .mock() }
}

private final class FakeProfileRepository: ProfileRepository, @unchecked Sendable {
    var updateCallCount = 0

    func fetchProfile() async throws -> Profile { .mock }

    func updateProfile(name: String?, email: String?) async throws -> Profile {
        updateCallCount += 1
        return Profile(name: name ?? "Chris", email: email ?? "chris@example.com", avatarURL: nil)
    }

    func uploadAvatar(imageData: Data) async throws -> Profile { .mock }
}

private final class FakeFavoriteRepository: FavoriteRepository, @unchecked Sendable {
    var stored: [Int: FavoriteApp] = [:]

    func observeFavorites() -> AsyncThrowingStream<[FavoriteApp], any Error> { AsyncThrowingStream { $0.finish() } }
    func observeIsFavorite(appID: Int) -> AsyncThrowingStream<Bool, any Error> { AsyncThrowingStream { $0.finish() } }
    func isFavorite(appID: Int) async throws -> Bool { stored[appID] != nil }
    func add(_ app: FavoriteApp) async throws { stored[app.id] = app }
    func remove(appID: Int) async throws { stored[appID] = nil }
}

// MARK: - Tests

@Suite("ProfileValidator")
struct ProfileValidatorTests {
    @Test("이름은 앞뒤 공백을 제거한 뒤 2~20자여야 한다", arguments: [
        ("  철수 ", "철수"),
        ("Chris", "Chris"),
    ])
    func validName(input: String, expected: String) throws {
        #expect(try ProfileValidator.validateName(input) == expected)
    }

    @Test("너무 짧거나 긴 이름은 거부한다")
    func invalidName() {
        #expect(throws: ValidationError.nameTooShort(minimum: 2)) { try ProfileValidator.validateName(" a ") }
        #expect(throws: ValidationError.nameTooLong(maximum: 20)) {
            try ProfileValidator.validateName(String(repeating: "가", count: 21))
        }
    }

    @Test("이메일 형식 검증", arguments: [
        ("chris@example.com", true),
        ("chris.kim+tag@mail.co.kr", true),
        ("chris@", false),
        ("chris@example", false),
        ("@example.com", false),
    ])
    func email(input: String, isValid: Bool) {
        let passed = (try? ProfileValidator.validateEmail(input)) != nil
        #expect(passed == isValid)
    }
}

@Suite("UseCases")
struct UseCaseTests {
    @Test("검색어 앞뒤 공백을 제거하고, 빈 검색어는 요청하지 않는다")
    func searchTrimsAndSkipsEmpty() async throws {
        let repository = FakeAppRepository()
        let useCase = SearchAppsUseCase.live(repository: repository)

        let empty = try await useCase.execute(term: "   ", page: .first)
        #expect(empty.items.isEmpty)
        #expect(repository.searchedTerms.isEmpty)

        _ = try await useCase.execute(term: "  kakao ", page: .first)
        #expect(repository.searchedTerms == ["kakao"])
    }

    @Test("잘못된 이름이면 서버에 요청하지 않고 validation 에러를 던진다")
    func invalidNameSkipsRequest() async {
        let repository = FakeProfileRepository()
        let useCase = ProfileUseCase.live(repository: repository)

        await #expect(throws: DomainError.validation(.nameTooShort(minimum: 2))) {
            try await useCase.updateName(name: "a")
        }
        #expect(repository.updateCallCount == 0)
    }

    @Test("즐겨찾기 토글은 추가 → 삭제를 번갈아 하고, 추가 시각은 date 의존성을 따른다")
    func toggleFavorite() async throws {
        let repository = FakeFavoriteRepository()
        let fixedDate = Date(timeIntervalSince1970: 1_234)
        let useCase = withDependencies {
            $0.date.now = fixedDate
        } operation: {
            FavoriteUseCase.live(repository: repository)
        }

        let added = try await withDependencies { $0.date.now = fixedDate } operation: {
            try await useCase.toggle(app: .mock)
        }
        #expect(added == true)
        #expect(repository.stored[AppSummary.mock.id]?.addedAt == fixedDate)

        let removed = try await useCase.toggle(app: .mock)
        #expect(removed == false)
        #expect(repository.stored.isEmpty)
    }

    @Test("Page.nextRequest는 남은 항목이 있을 때만 다음 offset을 준다")
    func pageNext() {
        let page = Page(items: Array(repeating: AppSummary.mock, count: 20), total: 45, offset: 20, limit: 20)
        #expect(page.nextRequest == PageRequest(offset: 40, limit: 20))

        let last = Page(items: Array(repeating: AppSummary.mock, count: 5), total: 45, offset: 40, limit: 20)
        #expect(last.nextRequest == nil)
    }
}
