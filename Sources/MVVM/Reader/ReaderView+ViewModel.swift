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
        private(set) var data: DisplayData
        
        init(comicId: String, episodeId: String) {
            self.data = .init(comicId: comicId, episodeId: episodeId)
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
            if data.episodeId == request.epidoseId {
                return
            }
            
            if let episodeId = request.epidoseId {
                data.episodeId = episodeId
            }
            
            if data.isLoading {
                return
            }
            
            data.isLoading = true
            
            Task {
                do {
                    let parser = Parser(parserConfiguration: .images(comicId: data.comicId, episodeId: data.episodeId))
                    parser.parserConfiguration.request = makeParseRequest()
                    let result = try await parser.anyResult()
                    let favorited = await ComicWorker.shared.getComic(id: data.comicId)?.favorited ?? false
                    let images = try await makeImagesWithParser(result: result)
                    let title = await getCurrentEpisode()?.title ?? ""
                    let prevEpisodeId = await getPrevEpisodeId()
                    let nextEpisodeId = await getNextEpisodeId()
                    data.favorited = favorited
                    data.images = images
                    data.title = title
                    data.prevEpesodeId = prevEpisodeId
                    data.nextEpesodeId = nextEpisodeId
                    data.isLoading = false
                }
                catch {
                    data.isLoading = false
                    data = .init()
                }
            }
        }

        private func actionUpdateFavorite() {
            Task {
                let comic = await ComicWorker.shared.getComic(id: data.comicId)
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

            await ComicWorker.shared.updateHistory(comicId: data.comicId, episodeId: data.comicId)
            
            return result
        }
        
        private func makeParseRequest() -> URLRequest {
            let uri = "https://tw.manhuagui.com/comic/\(data.comicId)/\(data.episodeId).html"
            let urlComponents = URLComponents(string: uri)!

            return .init(url: urlComponents.url!)
        }
        
        // MARK: - Get Something
        
        private func getCurrentEpisode() async -> Database.Episode? {
            let episodes = await ComicWorker.shared.getEpisodes(comicId: data.comicId)
            return episodes.first(where: { $0.id == data.episodeId })
        }
        
        private func getPrevEpisodeId() async -> String? {
            let episodes = await ComicWorker.shared.getEpisodes(comicId: data.comicId)
            
            guard let currentIndex = episodes.firstIndex(where: { $0.id == data.episodeId }) else {
                return nil
            }
            
            
            return episodes.first(where: { $0.index == currentIndex + 1 })?.id
        }
        
        private func getNextEpisodeId() async -> String? {
            let episodes = await ComicWorker.shared.getEpisodes(comicId: data.comicId)
            
            guard let currentIndex = episodes.firstIndex(where: { $0.id == data.episodeId }) else {
                return nil
            }
            
            
            return episodes.first(where: { $0.index == currentIndex - 1 })?.id
        }
    }
}
