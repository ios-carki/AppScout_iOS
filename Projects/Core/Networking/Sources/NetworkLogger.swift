import Alamofire
import Foundation
import os

/// DEBUG 빌드에서 요청·응답을 Xcode 콘솔(os.Logger)에 남긴다.
final class NetworkLogger: EventMonitor, @unchecked Sendable {
    let queue = DispatchQueue(label: "com.carki.appscout.networking.logger")
    private let logger = Logger(subsystem: "com.carki.appscout", category: "Network")

    func requestDidResume(_ request: Request) {
        guard let urlRequest = request.request else { return }
        logger.debug("➡️ \(urlRequest.httpMethod ?? "-", privacy: .public) \(urlRequest.url?.absoluteString ?? "-", privacy: .public)")
    }

    func request(_ request: DataRequest, didParseResponse response: DataResponse<Data, AFError>) {
        let status = response.response?.statusCode ?? -1
        let url = request.request?.url?.absoluteString ?? "-"
        let ms = Int((response.metrics?.taskInterval.duration ?? 0) * 1000)
        if (200..<300).contains(status) {
            logger.debug("✅ \(status) \(url, privacy: .public) (\(ms)ms)")
        } else {
            let body = response.data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            logger.error("❌ \(status) \(url, privacy: .public) \(body.prefix(300), privacy: .public)")
        }
    }
}
