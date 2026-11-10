// Data 모듈이 SQLiteData의 쿼리 API를 바로 쓸 수 있도록 다시 내보낸다.
@_exported import SQLiteData

import Foundation
import OSLog

private let logger = Logger(subsystem: "com.carki.appscout", category: "Database")

/// 앱 DB 연결을 만들고 마이그레이션까지 끝낸 뒤 돌려준다.
///
/// 앱 시작 시 한 번만 호출해서 `defaultDatabase` 의존성에 넣는다.
/// ```swift
/// prepareDependencies { $0.defaultDatabase = try! appDatabase() }
/// ```
/// `defaultDatabase(configuration:)`는 실행 환경(live / preview / test)에 따라
/// 앱용 파일 DB 또는 임시 DB를 알아서 만들어 준다.
public func appDatabase() throws -> any DatabaseWriter {
    @Dependency(\.context) var context
    var configuration = Configuration()
    configuration.foreignKeysEnabled = true
    #if DEBUG
    configuration.prepareDatabase { db in
        db.trace(options: .profile) {
            if context == .preview {
                print("\($0.expandedDescription)")
            } else {
                logger.debug("\($0.expandedDescription)")
            }
        }
    }
    #endif
    let database = try defaultDatabase(configuration: configuration)
    logger.info("open '\(database.path)'")
    try AppDatabaseMigrator.make().migrate(database)
    return database
}

/// 테스트용 메모리 DB (테스트마다 새로 만들어서 서로 영향이 없게 한다)
public func inMemoryAppDatabase() throws -> any DatabaseWriter {
    let database = try DatabaseQueue()
    try AppDatabaseMigrator.make().migrate(database)
    return database
}

/// 스키마 변경 이력.
///
/// 이미 배포된 마이그레이션은 절대 수정하지 않고, 변경이 필요하면 새 마이그레이션을 아래에 추가한다.
public enum AppDatabaseMigrator {
    public static func make() -> DatabaseMigrator {
        var migrator = DatabaseMigrator()
        #if DEBUG
        // 개발 중 스키마를 바꾸면 DB를 지우고 다시 만든다 (배포 빌드에는 적용되지 않음)
        migrator.eraseDatabaseOnSchemaChange = true
        #endif

        migrator.registerMigration("v1: create recentKeywords, favoriteApps") { db in
            try #sql(
                """
                CREATE TABLE "recentKeywords" (
                  "id" TEXT PRIMARY KEY NOT NULL,
                  "keyword" TEXT NOT NULL,
                  "searchedAt" TEXT NOT NULL
                ) STRICT
                """
            )
            .execute(db)

            try #sql(
                """
                CREATE INDEX "idx_recentKeywords_searchedAt"
                ON "recentKeywords" ("searchedAt" DESC)
                """
            )
            .execute(db)

            try #sql(
                """
                CREATE TABLE "favoriteApps" (
                  "id" INTEGER PRIMARY KEY NOT NULL,
                  "name" TEXT NOT NULL,
                  "sellerName" TEXT NOT NULL,
                  "iconURL" TEXT,
                  "primaryGenre" TEXT NOT NULL,
                  "averageRating" REAL NOT NULL,
                  "addedAt" TEXT NOT NULL
                ) STRICT
                """
            )
            .execute(db)
        }

        return migrator
    }
}
