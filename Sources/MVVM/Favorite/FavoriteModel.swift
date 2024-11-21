//
//  FavoriteModel.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

extension Favorite {
    
    // MARK: - Action / Request

    enum Action {
        case loadData
        case removeFavorite(request: RemoveFavoriteRequest)
    }

    struct RemoveFavoriteRequest {
        let comic: DisplayComic
    }

    // MARK: - Models
    
    struct DisplayComic: Identifiable {
        let id: String
        let title: String
        let coverURI: String
        let lastUpdate: TimeInterval
        let hasNew: Bool
        let note: String
        let watchDate: Date?
        
        init(comic: Database.Comic) {
            self.id = comic.id
            self.title = comic.title
            self.coverURI = comic.cover
            self.lastUpdate = comic.lastUpdate
            self.hasNew = comic.hasNew
            self.note = comic.note
            self.watchDate = comic.watchDate
        }
    }
}
