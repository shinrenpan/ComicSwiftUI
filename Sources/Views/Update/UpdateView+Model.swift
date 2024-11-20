//
//  UpdateModel.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit
import WebParser

extension UpdateView {
    
    // MARK: - Action / Request
    
    enum Action {
        case loadData
        case loadRemote
        case localSearch(request: LocalSearchRequest)
        case changeFavorite(request: ChangeFavoriteRequest)
    }
    
    struct LocalSearchRequest {
        let keywords: String
    }
    
    struct ChangeFavoriteRequest {
        let comic: DisplayComic
    }
    
    // MARK: - Models
    
    struct DisplayComic: Identifiable {
        let id: String
        let title: String
        let coverURI: String
        var favorited: Bool
        let lastUpdate: TimeInterval
        let hasNew: Bool
        let note: String
        let watchDate: Date?
        
        init(comic: Database.Comic) {
            self.id = comic.id
            self.title = comic.title
            self.coverURI = comic.cover
            self.favorited = comic.favorited
            self.lastUpdate = comic.lastUpdate
            self.hasNew = comic.hasNew
            self.note = comic.note
            self.watchDate = comic.watchDate
        }
    }
}
