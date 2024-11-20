//
//  HistoryVM.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import Observation
import UIKit

extension History {
    @MainActor
    @Observable
    final class VM {
        private(set) var dataSource: [DisplayComic] = []
        
        // MARK: - Public
        
        func doAction(_ action: Action) {
            switch action {
            case .loadData:
                actionLoadData()
            case let .changeFavorite(request):
                actionChangeFavorite(request: request)
            case let .removeHistory(request):
                actionRemoveHistory(request: request)
            }
        }
        
        // MARK: - Handle Action

        private func actionLoadData() {
            Task {
                let comics = await ComicWorker.shared.getHistories()
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
        
        private func actionRemoveHistory(request: RemoveHistoryRequest) {
            Task {
                let comic = request.comic
                await ComicWorker.shared.removeHistory(id: comic.id)
                dataSource.removeAll(where: { $0.id == comic.id })
            }
        }
    }
}
