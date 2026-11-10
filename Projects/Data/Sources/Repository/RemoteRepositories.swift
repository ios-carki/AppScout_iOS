import Domain
import Foundation
import Networking

/// 서버의 앱 정보 Repository 구현
public struct AppRepositoryImpl: AppRepository {
    private let client: any HTTPClient

    public init(client: any HTTPClient) {
        self.client = client
    }

    public func searchApps(term: String, page: PageRequest) async throws -> Page<AppSummary> {
        try await mapNetworkError { () async throws(NetworkError) in
            try await client.request(AppAPI.search(term: term, page: page), as: PageDTO<AppSummaryDTO>.self)
        }
        .toDomain()
    }

    public func fetchAppDetail(id: Int) async throws -> AppDetail {
        try await mapNetworkError { () async throws(NetworkError) in
            try await client.request(AppAPI.detail(id: id), as: AppDetailDTO.self)
        }
        .toDomain()
    }
}

/// 서버의 사용자 프로필 Repository 구현
public struct ProfileRepositoryImpl: ProfileRepository {
    private let client: any HTTPClient
    private let baseURL: URL
    private let imageCompressor: ImageCompressor

    /// - Parameter baseURL: 서버가 상대 경로로 준 아바타 URL을 풀 때 사용
    public init(client: any HTTPClient, baseURL: URL, imageCompressor: ImageCompressor = .default) {
        self.client = client
        self.baseURL = baseURL
        self.imageCompressor = imageCompressor
    }

    public func fetchProfile() async throws -> Profile {
        try await mapNetworkError { () async throws(NetworkError) in
            try await client.request(ProfileAPI.me, as: ProfileDTO.self)
        }
        .toDomain(baseURL: baseURL)
    }

    public func updateProfile(name: String?, email: String?) async throws -> Profile {
        let body = UpdateProfileRequestDTO(name: name, email: email)
        return try await mapNetworkError { () async throws(NetworkError) in
            try await client.request(ProfileAPI.update(body), as: ProfileDTO.self)
        }
        .toDomain(baseURL: baseURL)
    }

    public func uploadAvatar(imageData: Data) async throws -> Profile {
        // 원본(최대 20MB, HEIC 포함)을 긴 변 1024px JPEG로 줄여서 올린다.
        guard let jpeg = imageCompressor.compress(imageData) else {
            throw DomainError.validation(.server(message: "이미지를 읽을 수 없어요. 다른 사진을 선택해 주세요."))
        }
        let file = MultipartFile(fieldName: "file", fileName: "avatar.jpg", mimeType: "image/jpeg", data: jpeg)
        return try await mapNetworkError { () async throws(NetworkError) in
            try await client.upload(file, to: ProfileAPI.uploadAvatar, as: ProfileDTO.self)
        }
        .toDomain(baseURL: baseURL)
    }
}
