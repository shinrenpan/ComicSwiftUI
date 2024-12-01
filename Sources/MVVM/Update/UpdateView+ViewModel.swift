//
//  UpdateView+ViewModel.swift
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
        var data: DisplayData = .init()
        
        // MARK: - Public
        
        func doAction(_ action: Action) {
            switch action {
            case .loadData:
                actionLoadData()
            case .loadRemote:
                data.firstLoad = true
                actionLoadRemote()
            case let .changeFavorite(request):
                actionChangeFavorite(request: request)
            }
        }
        
        // MARK: - Handle Action

        private func actionLoadData() {
            Task {
                if data.keywords.isEmpty {
                    let comics = await ComicWorker.shared.getAll(fetchLimit: 1000)
                    data.comics = comics.compactMap { .init(comic: $0) }
                    actionLoadRemote()
                }
                else {
                    let comics = await ComicWorker.shared.getAll(keywords: data.keywords)
                    data.comics = comics.compactMap { .init(comic: $0) }
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
                    let parser = Parser(parserConfiguration: .update())
                    let result = try await parser.anyResult()
                    let array = AnyCodable(result).anyArray ?? [] 
                    await ComicWorker.shared.insertOrUpdateComics(array)
                    data.isLoading = false
                    actionLoadData()
                }
                catch {
                    data.isLoading = false
                    actionLoadData()
                }
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
