//
//  DetailVM.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import AnyCodable
import Observation
import UIKit
import WebParser

extension Detail {
    @MainActor
    @Observable
    final class VM {
        private(set) var comic = DisplayComic()
        private(set) var isLoading = false
        private let parser: Parser
        private let comicId: String
        private var firstLoad = true
        
        init(comicId: String) {
            self.comicId = comicId
            self.parser = .init(parserConfiguration: .detail(comicId: comicId))
        }
        
        // MARK: - Public
        
        func doAction(_ action: Action) {
            switch action {
            case .loadData:
                actionLoadData()
            case .loadRemote:
                actionLoadRemote()
            case .tapFavorite:
                actionTapFavorite()
            }
        }
        
        // MARK: - Handle Action
        
        private func actionLoadData() {
            Task {
                if let comic = await ComicWorker.shared.getComic(id: comicId) {
                    let episodes = await ComicWorker.shared.getEpisodes(comicId: comicId)
                    
                    let displayEpisodes: [DisplayEpisode] = episodes.compactMap {
                        let selected = comic.watchedId == $0.id
                        return .init(episode: $0, selected: selected)
                    }
                    
                    var displayComic = DisplayComic(comic: comic)
                    displayComic.episodes = displayEpisodes
                    self.comic = displayComic
                    actionLoadRemote()
                }
                else {
                    self.comic = .init()
                    actionLoadRemote()
                }
            }
        }

        private func actionLoadRemote() {
            if !firstLoad { return }
            firstLoad = false
            
            if isLoading { return }
            isLoading = true
            
            Task {
                do {
                    guard let comic = await ComicWorker.shared.getComic(id: comicId) else {
                        throw ParserError.timeout
                    }
                    
                    let result = try await parser.anyResult()
                    await handleLoadRemote(comic: comic, result: result)
                    isLoading = false
                    actionLoadData()
                }
                catch {
                    isLoading = false
                    actionLoadData()
                }
            }
        }

        private func actionTapFavorite() {
            Task {
                await ComicWorker.shared.getComic(id: comicId)?.favorited.toggle()
                comic.favorited.toggle()
            }
        }

        // MARK: - Handle Action Result

        private func handleLoadRemote(comic: Database.Comic, result: Any) async {
            let data = AnyCodable(result)
            comic.detail?.author = data["author"].string ?? ""
            comic.detail?.desc = data["desc"].string ?? ""

            let array = data["episodes"].anyArray ?? []

            let episodes: [Database.Episode] = array.compactMap {
                guard let id = $0["id"].string, !id.isEmpty else {
                    return nil
                }

                guard let title = $0["title"].string, !title.isEmpty else {
                    return nil
                }

                guard let index = $0["index"].int else {
                    return nil
                }

                return .init(id: id, index: index, title: title)
            }

            await ComicWorker.shared.updateEpisodes(id: comic.id, episodes: episodes)
        }
    }
}