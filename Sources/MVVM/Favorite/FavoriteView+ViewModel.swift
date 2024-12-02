//
//  FavoriteView+ViewModel.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import Observation
import UIKit

extension FavoriteView {
    @MainActor
    @Observable
    final class ViewModel {
        private(set) var comics: [DisplayComic] = []
        
        // MARK: - Public
        
        func doAction(_ action: Action) {
            switch action {
            case .loadData:
                actionLoadData()
            case let .removeFavorite(request):
                actionRemoveFavorite(request: request)
            }
        }
        
        // MARK: - Handle Action
        
        private func actionLoadData() {
            Task {
                let comics = await ComicWorker.shared.getFavorites()
                self.comics = comics.compactMap {.init(comic: $0) }
            }
        }

        private func actionRemoveFavorite(request: RemoveFavoriteRequest) {
            Task {
                let comic = request.comic
                await ComicWorker.shared.updateFavorite(id: comic.id, favorited: false)
                comics.removeAll(where: { $0.id == comic.id })
            }
        }
    }
}
