//
//  SearchView+ViewModel.swift
//
//  Created by Joe Pan on 2024/11/5.
//

import Observation
import WebParser
import AnyCodable

extension SearchView {
    @MainActor
    @Observable
    final class ViewModel {
        var keywords: String = ""
        private(set) var isLoading: Bool = false
        private(set) var comics: [DisplayComic] = []
        private(set) var hasNextPage: Bool = false
        private(set) var dataIsEmpty: Bool = false
        private var page: Int = 1
        
        // MARK: - Public

        func doAction(_ action: Action) {
            switch action {
            case .loadData:
                actionLoadData()
            case .loadNextPage:
                actionLoadNextPage()
            case let .changeFavorite(request):
                actionChangeFavorite(request: request)
            }
        }
        
        // MARK: - Handle Action
        
        private func actionLoadData() {
            page = 1
            
            if keywords.isEmpty { return }
            if isLoading { return }
            
            isLoading = true
            
            Task {
                do {
                    let parser = Parser(parserConfiguration: .search(keywords: self.keywords, page: self.page))
                    let result = try await parser.anyResult()
                    let array = AnyCodable(result).anyArray ?? []
                    let comics = await ComicWorker.shared.insertOrUpdateComics(array)
                    hasNextPage = comics.count >= 10
                    let displayComics: [DisplayComic] = comics.compactMap { .init(comic: $0) }
                    isLoading = false
                    self.comics = displayComics
                    dataIsEmpty = displayComics.isEmpty
                }
                catch {
                    isLoading = false
                    comics = []
                    dataIsEmpty = true
                }
            }
        }
        
        private func actionLoadNextPage() {
            if !hasNextPage { return }
            if keywords.isEmpty { return }
            if isLoading { return }
            
            isLoading = true
            
            page += 1
            Task {
                do {
                    let parser = Parser(parserConfiguration: .search(keywords: self.keywords, page: self.page))
                    let result = try await parser.anyResult()
                    let array = AnyCodable(result).anyArray ?? []
                    let comics = await ComicWorker.shared.insertOrUpdateComics(array)
                    hasNextPage = comics.count >= 10
                    let displayComics: [DisplayComic] = comics.compactMap { .init(comic: $0) }
                    isLoading = false
                    self.comics.append(contentsOf: displayComics)
                    dataIsEmpty = displayComics.isEmpty
                }
                catch {
                    isLoading = false
                    if page > 1 { page -= 1 }
                    dataIsEmpty = comics.isEmpty
                }
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
    }
}
