import Dependencies
import DependenciesMacros
import Foundation

// UseCase는 TCA 의존성(@DependencyClient)으로 만든다.
//
// - Domain: 인터페이스 + testValue/previewValue (TestDependencyKey)
// - App:    liveValue (DependencyKey) → 실제 RepositoryImpl을 연결
//
// 이렇게 나누면 Feature 모듈은 Data 모듈을 몰라도 되고,
// 테스트에서는 `withDependencies { $0.searchAppsUseCase.execute = { ... } }`로 바꿔 끼울 수 있다.

// MARK: - 앱 검색

@DependencyClient
public struct SearchAppsUseCase: Sendable {
    /// 검색어로 앱 목록 한 페이지를 가져온다. 검색어가 비어 있으면 요청하지 않고 빈 페이지를 돌려준다.
    public var execute: @Sendable (_ term: String, _ page: PageRequest) async throws -> Page<AppSummary>
}

extension SearchAppsUseCase {
    public static func live(repository: any AppRepository) -> Self {
        Self(execute: { term, page in
            let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return .empty(page) }
            return try await repository.searchApps(term: trimmed, page: page)
        })
    }
}

extension SearchAppsUseCase: TestDependencyKey {
    public static let testValue = Self()
    public static let previewValue = Self(execute: { term, page in
        try await Task.sleep(for: .milliseconds(400))
        let items = AppSummary.mocks.filter {
            term.isEmpty || $0.name.localizedCaseInsensitiveContains(term) || $0.primaryGenre.contains(term)
        }
        let slice = Array(items.dropFirst(page.offset).prefix(page.limit))
        return Page(items: slice, total: items.count, offset: page.offset, limit: page.limit)
    })
}

// MARK: - 앱 상세

@DependencyClient
public struct FetchAppDetailUseCase: Sendable {
    public var execute: @Sendable (_ id: Int) async throws -> AppDetail
}

extension FetchAppDetailUseCase {
    public static func live(repository: any AppRepository) -> Self {
        Self(execute: { id in try await repository.fetchAppDetail(id: id) })
    }
}

extension FetchAppDetailUseCase: TestDependencyKey {
    public static let testValue = Self()
    public static let previewValue = Self(execute: { id in
        try await Task.sleep(for: .milliseconds(400))
        guard let summary = AppSummary.mocks.first(where: { $0.id == id }) else {
            throw DomainError.notFound
        }
        return .mock(summary: summary)
    })
}

// MARK: - DependencyValues

extension DependencyValues {
    public var searchAppsUseCase: SearchAppsUseCase {
        get { self[SearchAppsUseCase.self] }
        set { self[SearchAppsUseCase.self] = newValue }
    }

    public var fetchAppDetailUseCase: FetchAppDetailUseCase {
        get { self[FetchAppDetailUseCase.self] }
        set { self[FetchAppDetailUseCase.self] = newValue }
    }
}
