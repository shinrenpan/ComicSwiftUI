//
//  HistoryView+Model.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import UIKit

extension HistoryView {
    
    // MARK: - Action / Request
    
    enum Action {
        case loadData
        case changeFavorite(request: ChangeFavoriteRequest)
        case removeHistory(request: RemoveHistoryRequest)
    }
    
    struct ChangeFavoriteRequest {
        let comic: DisplayComic
    }
    
    struct RemoveHistoryRequest {
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
    
    struct DisplayData {
        var comics: [DisplayComic] = []
    }
}
