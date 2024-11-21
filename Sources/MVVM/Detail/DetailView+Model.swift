//
//  DetailView+Model.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit

extension DetailView {
        
    // MARK: - Action / Request
    
    enum Action {
        case loadData
        case loadRemote
        case tapFavorite
    }
    
    // MARK: - Models
    
    struct DisplayComic {
        let title: String
        let author: String
        let description: String?
        let coverURI: String
        var favorited: Bool
        var episodes: [DisplayEpisode] = []
        
        init() {
            title = ""
            author = ""
            description = nil
            coverURI = ""
            favorited = false
        }
        
        init(comic: Database.Comic) {
            self.title = comic.title
            self.author = comic.detail?.author ?? "Unknown"
            self.description = comic.detail?.desc
            self.coverURI = comic.cover
            self.favorited = comic.favorited
        }
    }
    
    struct DisplayEpisode: Identifiable {
        let id: String
        let title: String
        let selected: Bool
        
        init(episode: Database.Episode, selected: Bool) {
            self.id = episode.id
            self.title = episode.title
            self.selected = selected
        }
    }
}
