import Database
import Domain
import Foundation

/// 로컬 DB의 즐겨찾기 Repository 구현 (SQLiteData)
public struct FavoriteRepositoryImpl: FavoriteRepository {
    private let database: any DatabaseWriter

    public init(database: any DatabaseWriter) {
        self.database = database
    }

    public func observeFavorites() -> AsyncThrowingStream<[FavoriteApp], any Error> {
        observe(in: database) { db in
            try FavoriteAppRecord
                .order { $0.addedAt.desc() }
                .fetchAll(db)
                .map { $0.toDomain() }
        }
    }

    public func observeIsFavorite(appID: Int) -> AsyncThrowingStream<Bool, any Error> {
        observe(in: database) { db in
            try FavoriteAppRecord.find(appID).fetchCount(db) > 0
        }
    }

    public func isFavorite(appID: Int) async throws -> Bool {
        try await mapStorageError {
            try await database.read { db in
                try FavoriteAppRecord.find(appID).fetchCount(db) > 0
            }
        }
    }

    public func add(_ app: FavoriteApp) async throws {
        try await mapStorageError {
            try await database.write { db in
                try FavoriteAppRecord.upsert { FavoriteAppRecord(app) }.execute(db)
            }
        }
    }

    public func remove(appID: Int) async throws {
        try await mapStorageError {
            try await database.write { db in
                try FavoriteAppRecord.find(appID).delete().execute(db)
            }
        }
    }
}

/// 로컬 DB의 최근 검색어 Repository 구현 (SQLiteData)
public struct RecentKeywordRepositoryImpl: RecentKeywordRepository {
    private let database: any DatabaseWriter

    public init(database: any DatabaseWriter) {
        self.database = database
    }

    public func observeRecentKeywords(limit: Int) -> AsyncThrowingStream<[RecentKeyword], any Error> {
        observe(in: database) { db in
            try RecentKeywordRecord
                .order { $0.searchedAt.desc() }
                .limit(limit)
                .fetchAll(db)
                .map { $0.toDomain() }
        }
    }

    public func save(keyword: String, searchedAt: Date, maxCount: Int) async throws {
        let record = RecentKeywordRecord(
            id: RecentKeyword.normalize(keyword),
            keyword: keyword,
            searchedAt: searchedAt
        )
        try await mapStorageError {
            try await database.write { db in
                // 같은 검색어면 시간과 표기만 갱신 (중복 행이 생기지 않음)
                try RecentKeywordRecord.upsert { record }.execute(db)

                // 최대 개수를 넘는 오래된 검색어 정리
                let overflowIDs = try RecentKeywordRecord
                    .order { $0.searchedAt.desc() }
                    .fetchAll(db)
                    .dropFirst(maxCount)
                    .map(\.id)
                if !overflowIDs.isEmpty {
                    try RecentKeywordRecord
                        .where { $0.id.in(overflowIDs) }
                        .delete()
                        .execute(db)
                }
            }
        }
    }

    public func delete(id: String) async throws {
        try await mapStorageError {
            try await database.write { db in
                try RecentKeywordRecord.find(id).delete().execute(db)
            }
        }
    }

    public func deleteAll() async throws {
        try await mapStorageError {
            try await database.write { db in
                try RecentKeywordRecord.delete().execute(db)
            }
        }
    }
}

// MARK: - DB 변경 관찰

/// GRDB의 ValueObservation을 AsyncThrowingStream으로 감싼다.
///
/// `fetch`가 읽는 테이블이 바뀔 때마다 새 값을 방출한다.
/// Feature에서는 `.run { send in for try await value in stream { ... } }`로 구독하고,
/// 화면이 사라지면 Effect가 취소되면서 관찰도 함께 끝난다.
private func observe<Value: Sendable>(
    in database: any DatabaseWriter,
    _ fetch: @escaping @Sendable (Database) throws -> Value
) -> AsyncThrowingStream<Value, any Error> {
    AsyncThrowingStream { continuation in
        let task = Task {
            do {
                for try await value in ValueObservation.tracking(fetch).values(in: database) {
                    continuation.yield(value)
                }
                continuation.finish()
            } catch is CancellationError {
                continuation.finish()
            } catch {
                continuation.finish(throwing: DomainError.storage)
            }
        }
        continuation.onTermination = { _ in task.cancel() }
    }
}
