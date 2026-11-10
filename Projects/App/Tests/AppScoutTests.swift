import Foundation
import Testing
@testable import AppScout

@Suite("AppScout")
struct AppScoutTests {
    /// 유닛 테스트는 앱을 호스트로 실행하므로 Bundle.main = AppScout.app
    @Test("xcconfig의 API_BASE_URL이 Info.plist를 거쳐 올바른 URL로 들어간다")
    func baseURLFromInfoPlist() throws {
        let raw = try #require(Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String)
        let url = try #require(URL(string: raw))
        #expect(url.scheme == "http" || url.scheme == "https")
        #expect(url.host() != nil)
    }
}
