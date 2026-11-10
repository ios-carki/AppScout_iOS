import Foundation
import Testing
@testable import Database

@Suite("Database")
struct DatabaseTests {
    let database: any DatabaseWriter

    init() throws {
        database = try inMemoryAppDatabase()
    }

    @Test("마이그레이션 후 두 테이블이 존재한다")
    func tablesExist() throws {
        let tables = try database.read { db in
            try String.fetchAll(db, sql: "SELECT name FROM sqlite_master WHERE type = 'table'")
        }
        #expect(tables.contains("recentKeywords"))
        #expect(tables.contains("favoriteApps"))
    }

    @Test("같은 id로 upsert하면 행이 늘지 않고 값만 갱신된다")
    func upsertRecentKeyword() throws {
        let first = Date(timeIntervalSince1970: 1_000)
        let second = Date(timeIntervalSince1970: 2_000)
        try database.write { db in
            try RecentKeywordRecord.upsert {
                RecentKeywordRecord(id: "kakao", keyword: "Kakao", searchedAt: first)
            }
            .execute(db)
            try RecentKeywordRecord.upsert {
                RecentKeywordRecord(id: "kakao", keyword: "kakao", searchedAt: second)
            }
            .execute(db)
        }
        let rows = try database.read { db in try RecentKeywordRecord.all.fetchAll(db) }
        #expect(rows.count == 1)
        #expect(rows.first?.keyword == "kakao")
        #expect(rows.first?.searchedAt == second)
    }

    @Test("즐겨찾기를 최신순으로 조회하고 삭제할 수 있다")
    func favoritesOrderAndDelete() throws {
        try database.write { db in
            for (id, time) in [(1, 100.0), (2, 300.0), (3, 200.0)] {
                try FavoriteAppRecord.insert {
                    FavoriteAppRecord(
                        id: id, name: "App \(id)", sellerName: "Seller", iconURL: nil,
                        primaryGenre: "유틸리티", averageRating: 4, addedAt: Date(timeIntervalSince1970: time)
                    )
                }
                .execute(db)
            }
            try FavoriteAppRecord.find(3).delete().execute(db)
        }
        let ids = try database.read { db in
            try FavoriteAppRecord.order { $0.addedAt.desc() }.fetchAll(db).map(\.id)
        }
        #expect(ids == [2, 1])
    }
}
