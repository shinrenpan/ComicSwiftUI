//
//  RemoteSearchFeature.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/13.
//

import ComposableArchitecture
import AnyCodable

@Reducer
struct RemoteSearchFeature {
    @ObservableState
    struct State: Equatable {
        var comics: [Comic] = []
        var page = 1
        var isLoading = false
        var canLoadMore = false
        var searchKey = ""
        @Presents var destination: Router.Navigation.State?
    }
    
    enum Action: Equatable {
        case loadData
        case loadMore
        case loadDataFailure
        case loadDataSuccess(AnyCodable)
        case comicsUpdated([Comic])
        case favoriteButtonTapped(Comic)
        case searchKeyChanged(String)
        case comicTapped(Comic)
        case destination((PresentationAction<Router.Navigation.Action>))
    }
    
    @Dependency(\.comicParser) var parser
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadData:
                if state.searchKey.isEmpty {
                    return .none
                }
                
                if state.isLoading {
                    return .none
                }
                
                state.page = 1
                state.isLoading = true
                LoadingActor.isLoading = true
                
                return .run {[keywords = state.searchKey, page = state.page] send in
                    do {
                        let data = try await parser.search(keywords: keywords, page: page)
                        await send(.loadDataSuccess(data))
                    }
                    catch {
                        await send(.loadDataFailure)
                    }
                }
                
            case .loadMore:
                if !state.canLoadMore {
                    return .none
                }
                
                if state.searchKey.isEmpty {
                    return .none
                }
                
                if state.isLoading {
                    return .none
                }
                
                LoadingActor.isLoading = true
                state.isLoading = true
                
                return .run {[keywords = state.searchKey, page = state.page] send in
                    do {
                        let data = try await parser.search(keywords: keywords, page: page)
                        await send(.loadDataSuccess(data))
                    }
                    catch {
                        await send(.loadDataFailure)
                    }
                }
                
            case .loadDataFailure:
                LoadingActor.isLoading = false
                state.isLoading = false
                return .none
                
            case let .loadDataSuccess(data):
                return .run { send in
                    let comics = await Storage.shared.insertOrUpdateComics(data.anyArray ?? [])
                    await send(.comicsUpdated(comics))
                }
                
            case let .comicsUpdated(comics):
                LoadingActor.isLoading = false
                state.isLoading = false
                
                if state.page == 1 { // 第一次 Load
                    state.comics = comics
                }
                else {
                    state.comics.append(contentsOf: comics)
                }
                
                state.page += 1
                state.canLoadMore = comics.count >= 10
                return .none
                
            case let .favoriteButtonTapped(comic):
                comic.favorited.toggle()
                return .none
                
            case let .searchKeyChanged(searchKey):
                state.searchKey = searchKey
                return .none
                
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
