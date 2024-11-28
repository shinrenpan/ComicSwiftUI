//
//  ReaderView+ViewModel.swift
//
//  Created by Shinren Pan on 2024/5/24.
//

import AnyCodable
import Observation
import UIKit
import WebParser

extension ReaderView {
    @MainActor
    @Observable
    final class ViewModel {
        private(set) var data = DisplayData()
        let comicId: String
        private(set) var episodeId: String
        private let parser: Parser
        
        init(comicId: String, episodeId: String) {
            self.comicId = comicId
            self.episodeId = episodeId
            self.parser = .init(parserConfiguration: .images(comicId: comicId, episodeId: episodeId))
        }
        
        // MARK: - Public
        
        func doAction(_ action: Action) {
            switch action {
            case let .loadData(request):
                actionLoadData(request: request)
            case .updateFavorite:
                actionUpdateFavorite()
            case .loadPrev:
                actionLoadPrev()
            case .loadNext:
                actionLoadNext()
            case .reloadHiddenBars:
                data.hiddenBars.toggle()
            case .updateReadDirection:
                data.isHorizontal.toggle()
            }
        }
        
        // MARK: - Handle Action

        private func actionLoadData(request: LoadDataRequest) {
            if let episodeId = request.epidoseId {
                self.episodeId = episodeId
            }
            
            if data.isLoading {
                return
            }
            
            data.isLoading = true
            parser.parserConfiguration.request = makeParseRequest()
            
            Task {
                do {
                    data.isLoading = false
                    let result = try await parser.anyResult()
                    let favorited = await ComicWorker.shared.getComic(id: comicId)?.favorited ?? false
                    let images = try await makeImagesWithParser(result: result)
                    let title = await getCurrentEpisode()?.title ?? ""
                    let prevEpisodeId = await getPrevEpisodeId()
                    let nextEpisodeId = await getNextEpisodeId()
                    data = .init(
                        title: title,
                        images: images,
                        favorited: favorited,
                        hasPrev: prevEpisodeId != nil,
                        hasNext: nextEpisodeId != nil
                    )
                }
                catch {
                    data.isLoading = false
                    data = .init()
                }
            }
        }

        private func actionUpdateFavorite() {
            Task {
                let comic = await ComicWorker.shared.getComic(id: comicId)
                comic?.favorited.toggle()
                data.favorited.toggle()
            }
        }
        
        private func actionLoadPrev() {
            Task {
                if let prevEpisodeId = await getPrevEpisodeId() {
                    actionLoadData(request: .init(epidoseId: prevEpisodeId))
                }
            }
        }

        private func actionLoadNext() {
            Task {
                if let nextEpisodeId = await getNextEpisodeId() {
                    actionLoadData(request: .init(epidoseId: nextEpisodeId))
                }
            }
        }
        
        // MARK: - Make Something

        private func makeImagesWithParser(result: Any) async throws -> [ImageData] {
            let array = AnyCodable(result).anyArray ?? []

            let result: [ImageData] = array.compactMap {
                guard let uri = $0["uri"].string, !uri.isEmpty else {
                    return nil
                }

                guard let uriDecode = uri.removingPercentEncoding else {
                    return nil
                }

                return .init(uri: uriDecode)
            }

            /*
            if result.isEmpty {
                throw LoadImageError.empty
            }*/
            
            await ComicWorker.shared.updateHistory(comicId: comicId, episodeId: episodeId)
            
            return result
        }
        
        private func makeParseRequest() -> URLRequest {
            let uri = "https://tw.manhuagui.com/comic/\(comicId)/\(episodeId).html"
            let urlComponents = URLComponents(string: uri)!

            return .init(url: urlComponents.url!)
        }
        
        // MARK: - Get Something
        
        private func getCurrentEpisode() async -> Database.Episode? {
            let episodes = await ComicWorker.shared.getEpisodes(comicId: comicId)
            return episodes.first(where: { $0.id == episodeId })
        }
        
        private func getPrevEpisodeId() async -> String? {
            let episodes = await ComicWorker.shared.getEpisodes(comicId: comicId)
            
            guard let currentIndex = episodes.firstIndex(where: { $0.id == episodeId }) else {
                return nil
            }
            
            
            return episodes.first(where: { $0.index == currentIndex + 1 })?.id
        }
        
        private func getNextEpisodeId() async -> String? {
            let episodes = await ComicWorker.shared.getEpisodes(comicId: comicId)
            
            guard let currentIndex = episodes.firstIndex(where: { $0.id == episodeId }) else {
                return nil
            }
            
            
            return episodes.first(where: { $0.index == currentIndex - 1 })?.id
        }
    }
}
