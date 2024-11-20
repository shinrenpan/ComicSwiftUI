//
//  UpdateVM.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import AnyCodable
import Observation
import UIKit
import WebParser

extension UpdateView {
    @MainActor
    @Observable
    final class ViewModel {
        private(set) var dataSource: [DisplayComic] = []
        private(set) var isLoading = false
        private var firstLoad = true
        private let parser = Parser(parserConfiguration: .update())
        
        // MARK: - Public
        
        func doAction(_ action: Action) {
            switch action {
            case .loadData:
                actionLoadData()
            case .loadRemote:
                firstLoad = true
                actionLoadRemote()
            case let .localSearch(request):
                actionLocalSearch(request: request)
            case let .changeFavorite(request):
                actionChangeFavorite(request: request)
            }
        }
        
        // MARK: - Handle Action

        private func actionLoadData() {
            Task {
                let comics = await ComicWorker.shared.getAll(fetchLimit: 1000)
                dataSource = comics.compactMap { .init(comic: $0) }
                actionLoadRemote()
            }
        }

        private func actionLoadRemote() {
            if !firstLoad { return }
            firstLoad = false
            
            if isLoading { return }
            isLoading = true
            
            Task {
                do {
                    let result = try await parser.anyResult()
                    let array = AnyCodable(result).anyArray ?? [] 
                    await ComicWorker.shared.insertOrUpdateComics(array)
                    isLoading = false
                    actionLoadData()
                }
                catch {
                    isLoading = false
                    actionLoadData()
                }
            }
        }

        private func actionLocalSearch(request: LocalSearchRequest) {
            Task {
                let comics = await ComicWorker.shared.getAll(keywords: request.keywords)
                dataSource = comics.compactMap { .init(comic: $0) }
            }
        }

        private func actionChangeFavorite(request: ChangeFavoriteRequest) {
            Task {
                let comic = request.comic
                
                if let _ = await ComicWorker.shared.updateFavorite(id: comic.id, favorited: !comic.favorited) {
                    actionLoadData()
                }
            }
        }
    }
}
