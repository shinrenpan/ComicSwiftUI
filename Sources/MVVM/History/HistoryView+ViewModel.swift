//
//  HistoryView+ViewModel.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import Observation
import UIKit

extension HistoryView {
    @MainActor
    @Observable
    final class ViewModel {
        private(set) var comics: [DisplayComic] = []
        
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
                self.comics = comics.compactMap { .init(comic: $0) }
            }
        }

        private func actionChangeFavorite(request: ChangeFavoriteRequest) {
            Task {
                let comic = request.comic
                
                if let _ = await ComicWorker.shared.updateFavorite(id: comic.id, favorited: !comic.favorited) {
                    comics.indices
                        .filter { comics[$0].id == comic.id }
                        .forEach { comics[$0].favorited.toggle() }
                }
            }
        }
        
        private func actionRemoveHistory(request: RemoveHistoryRequest) {
            Task {
                let comic = request.comic
                await ComicWorker.shared.removeHistory(id: comic.id)
                comics.removeAll(where: { $0.id == comic.id })
            }
        }
    }
}
