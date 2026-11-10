import Data
import Database
import Dependencies
import Domain
import Foundation
import Networking

// 조립 지점(Composition Root).
//
// Domain에 선언된 UseCase 인터페이스(TestDependencyKey)에 실제 구현(liveValue)을 연결한다.
// Feature 모듈은 Data·Networking·Database를 전혀 모르고, @Dependency(\.searchAppsUseCase)만 쓴다.
// TCA 문서의 "interface / live 모듈 분리" 패턴:
// https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/livepreviewtest

private enum Live {
    static let baseURL = APIConfiguration.baseURL()
    static let httpClient: any HTTPClient = AlamofireHTTPClient(baseURL: baseURL)
    static let appRepository = AppRepositoryImpl(client: httpClient)
    static let profileRepository = ProfileRepositoryImpl(client: httpClient, baseURL: baseURL)

    /// `AppScoutApp.init`의 prepareDependencies에서 설정한 DB를 꺼낸다.
    static var database: any DatabaseWriter {
        @Dependency(\.defaultDatabase) var database
        return database
    }
}

extension SearchAppsUseCase: @retroactive DependencyKey {
    public static let liveValue = SearchAppsUseCase.live(repository: Live.appRepository)
}

extension FetchAppDetailUseCase: @retroactive DependencyKey {
    public static let liveValue = FetchAppDetailUseCase.live(repository: Live.appRepository)
}

extension ProfileUseCase: @retroactive DependencyKey {
    public static let liveValue = ProfileUseCase.live(repository: Live.profileRepository)
}

extension FavoriteUseCase: @retroactive DependencyKey {
    public static var liveValue: FavoriteUseCase {
        .live(repository: FavoriteRepositoryImpl(database: Live.database))
    }
}

extension RecentKeywordUseCase: @retroactive DependencyKey {
    public static var liveValue: RecentKeywordUseCase {
        .live(repository: RecentKeywordRepositoryImpl(database: Live.database))
    }
}
