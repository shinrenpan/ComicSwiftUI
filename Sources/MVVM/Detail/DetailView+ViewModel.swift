//
//  Detail+ViewModel.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import AnyCodable
import Observation
import UIKit
import WebParser

extension DetailView {
    @MainActor
    @Observable
    final class ViewModel {
        private(set) var data: DisplayData
        
        init(comicId: String) {
            self.data = .init(comicId: comicId)
        }
        
        // MARK: - Public
        
        func doAction(_ action: Action) {
            switch action {
            case .loadData:
                actionLoadData()
            case .loadRemote:
                data.firstLoad = true
                actionLoadRemote()
            case .tapFavorite:
                actionTapFavorite()
            }
        }
        
        // MARK: - Handle Action
        
        private func actionLoadData() {
            Task {
                if let comic = await ComicWorker.shared.getComic(id: data.comicId) {
                    let episodes = await ComicWorker.shared.getEpisodes(comicId: data.comicId)
                    
                    let displayEpisodes: [DisplayEpisode] = episodes.compactMap {
                        let selected = comic.watchedId == $0.id
                        return .init(episode: $0, selected: selected)
                    }
                    
                    var displayComic = DisplayComic(comic: comic)
                    displayComic.episodes = displayEpisodes
                    data.comic = displayComic
                    actionLoadRemote()
                }
                else {
                    data.comic = .init()
                    actionLoadRemote()
                }
            }
        }

        private func actionLoadRemote() {
            if !data.firstLoad { return }
            data.firstLoad = false
            
            if data.isLoading { return }
            data.isLoading = true
            
            Task {
                do {
                    guard let comic = await ComicWorker.shared.getComic(id: data.comicId) else {
                        throw ParserError.timeout
                    }
                    
                    let parser = Parser(parserConfiguration: .detail(comicId: data.comicId))
                    let result = try await parser.anyResult()
                    await handleLoadRemote(comic: comic, result: result)
                    data.isLoading = false
                    actionLoadData()
                }
                catch {
                    data.isLoading = false
                    actionLoadData()
                }
            }
        }

        private func actionTapFavorite() {
            Task {
                await ComicWorker.shared.getComic(id: data.comicId)?.favorited.toggle()
                data.comic.favorited.toggle()
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
