import Foundation

/// 서버 주소 설정.
///
/// 값의 흐름: `Configs/Shared.xcconfig`의 `API_BASE_URL` → Info.plist `APIBaseURL` → 여기.
/// 코드에 주소를 하드코딩하지 않아서, 빌드 구성(Debug/Release)별로 서버를 바꿀 수 있다.
public enum APIConfiguration {
    public static let infoPlistKey = "APIBaseURL"

    /// Info.plist에서 baseURL을 읽는다. 값이 없거나 잘못되면 로컬 서버로 대체한다.
    public static func baseURL(bundle: Bundle = .main) -> URL {
        if let raw = bundle.object(forInfoDictionaryKey: infoPlistKey) as? String,
           !raw.isEmpty,
           let url = URL(string: raw) {
            return url
        }
        assertionFailure("Info.plist에 \(infoPlistKey)가 없습니다. Configs/*.xcconfig를 확인하세요.")
        return URL(string: "http://localhost:8000")!
    }
}
