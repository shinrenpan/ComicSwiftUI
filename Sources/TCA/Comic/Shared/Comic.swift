//
//  Comic.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/12.
//

import SwiftData
import Foundation

@Model
final class Comic: @unchecked Sendable {
    /// Id
    @Attribute(.unique) private(set) var id: String

    /// Title
    var title: String

    var cover: String
    
    /// 更新至...
    var note: String

    /// 最後更新時間
    var lastUpdate: TimeInterval

    /// 是否收藏
    var favorited: Bool

    /// Detail
    @Relationship(deleteRule: .cascade, inverse: \Detail.comic) var detail: Detail?

    /// 集數
    @Relationship(deleteRule: .cascade, inverse: \Episode.comic) var episodes: [Episode]?

    /// 最後觀看集數 Id
    var watchedId: String?

    /// 最後觀看時間
    var watchDate: Date?

    var hasNew: Bool

    init(id: String, title: String, cover: String, note: String, lastUpdate: TimeInterval, favorited: Bool, detail: Detail? = nil, episodes: [Episode]? = nil, watchedId: String? = nil, watchDate: Date? = nil, hasNew: Bool) {
        self.id = id
        self.title = title
        self.cover = cover
        self.note = note
        self.lastUpdate = lastUpdate
        self.favorited = favorited
        self.detail = detail
        self.episodes = episodes
        self.watchedId = watchedId
        self.watchDate = watchDate
        self.hasNew = hasNew
    }
}

// MARK: - Functions

extension Comic {
    func updateHasNew() {
        hasNew = hasVew()
    }

    func hasVew() -> Bool {
        guard let watchDate else {
            return true
        }

        if lastUpdate > watchDate.timeIntervalSince1970 {
            return true
        }

        // 最新集數 id != 看過的 id
        return episodes?.first(where: { $0.index == 0 })?.id != watchedId
    }
}

// MARK: - Detail

extension Comic {
    @Model
    final class Detail: @unchecked Sendable {
        var comic: Comic?
        /// 描述
        var desc: String
        /// 作者
        var author: String

        init(comic: Comic? = nil, desc: String, author: String) {
            self.comic = comic
            self.desc = desc
            self.author = author
        }
    }
}

// MARK: - Episode

extension Comic {
    @Model
    final class Episode: @unchecked Sendable {
        var comic: Comic?
        /// Id
        private(set) var id: String
        /// Index
        private(set) var index: Int
        /// Title
        private(set) var title: String

        init(comic: Comic? = nil, id: String, index: Int, title: String) {
            self.comic = comic
            self.id = id
            self.index = index
            self.title = title
        }
    }
}

// MARK: - Mock

extension Comic {
    nonisolated(unsafe) static let rawMock: [String: Any] = [
        "id": "1128",
        "title": "ONE PIECE航海王",
        "cover": "//cf.mhgui.com/cpic/m/1128.jpg",
        "note": "9999",
        "lastUpdate": Date.now.timeIntervalSince1970,
        "favorited": Bool.random(),
        "hasNew": Bool.random(),
    ]
    
    static let mock: Comic = .init(
        id: "1128",
        title: "ONE PIECE航海王",
        cover: "//cf.mhgui.com/cpic/m/1128.jpg",
        note: "9999",
        lastUpdate: Date.now.timeIntervalSince1970,
        favorited: Bool.random(),
        hasNew: Bool.random()
    )
}
