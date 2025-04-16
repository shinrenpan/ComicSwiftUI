//
//  FavoriteFeature.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/12.
//

import ComposableArchitecture
import AnyCodable

@Reducer
struct FavoriteFeature {
    @ObservableState
    struct State: Equatable {
        var comics: [Comic] = []
        var searchKey = ""
        var contentViewState: ContentViewState = .success
        @Presents var destination: Router.Navigation.State?
    }
    
    enum Action: Equatable {
        case loadCache
        case comicsLoaded([Comic])
        case searchKeyChanged(String)
        case favoriteButtonTapped(Comic)
        case comicTapped(Comic)
        case destination((PresentationAction<Router.Navigation.Action>))
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadCache:
                return .run { send in
                    let comics = await Storage.shared.getFavorites()
                    await send(.comicsLoaded(comics))
                }
                
            case let .searchKeyChanged(key):
                state.searchKey = key
                
                return .run { send in
                    let comics = await Storage.shared.getFavorites(keywords: key)
                    await send(.comicsLoaded(comics))
                }
              
            case let .comicsLoaded(comics):
                state.comics = comics
                state.contentViewState = comics.isEmpty ? .empty : .success
                return .none
                
            case let .favoriteButtonTapped(comic):
                comic.favorited = false
                
                return .run { send in
                    await send(.loadCache)
                }
                
            case let .comicTapped(comic):
                state.destination = .detailView(.init(comic: comic))
                return .none
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

// MARK: - ContentViewState

extension FavoriteFeature {
    enum ContentViewState {
        case empty
        case success
    }
}
