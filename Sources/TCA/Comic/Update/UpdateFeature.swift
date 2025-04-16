//
//  UpdateFeature.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/12.
//

import ComposableArchitecture
import AnyCodable

@Reducer
struct UpdateFeature {
    @ObservableState
    struct State: Equatable {
        var comics: [Comic] = []
        var firstLoad = true
        var searchKey = ""
        var contentViewState: ContentViewState = .success
        @Presents var destination: Router.Navigation.State?
    }
    
    enum Action: Equatable {
        case firstLoad
        case loadCache
        case loadRemote
        case loadRemoteFailure
        case loadRemoteSuccess(AnyCodable)
        case comicsLoaded([Comic])
        case searchKeyChanged(String)
        case pullToRefresh
        case favoriteButtonTapped(Comic)
        case remoteSearchButtonTapped
        case comicTapped(Comic)
        case destination((PresentationAction<Router.Navigation.Action>))
    }
    
    @Dependency(\.comicParser) var parser
    @Dependency(\.continuousClock) var clock
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .firstLoad:
                if !state.firstLoad {
                    return .none
                }
                
                return .run { send in
                    await send(.loadCache)
                }
                
            case .loadCache:
                return .run { send in
                    let comics = await Storage.shared.getAll()
                    await send(.comicsLoaded(comics))
                }
              
            case let .searchKeyChanged(key):
                state.searchKey = key
                
                return .run { send in
                    let comics = await Storage.shared.getAll(keywords: key)
                    await send(.comicsLoaded(comics))
                }
              
            case .pullToRefresh:
                state.searchKey = ""
                
                return .run { send in
                    await send(.loadRemote)
                }
                
            case .loadRemote:
                LoadingActor.isLoading = true
                
                return .run { send in
                    do {
                        let data = try await parser.updateList()
                        await send(.loadRemoteSuccess(data))
                    }
                    catch {
                        await send(.loadRemoteFailure)
                    }
                }
            
            case .loadRemoteFailure:
                LoadingActor.isLoading = false
                state.contentViewState = .failure
                return .none
                
            case let .loadRemoteSuccess(data):
                return .run { send in
                    let comics = await Storage.shared.insertOrUpdateComics(data.anyArray ?? [])
                    await send(.comicsLoaded(comics))
                }
                
            case let .comicsLoaded(comics):
                LoadingActor.isLoading = false
                state.comics = comics
                state.contentViewState = .success
                
                if !state.firstLoad {
                    return .none
                }
                
                state.firstLoad = false
                
                return .run { send in
                    try await clock.sleep(for: .milliseconds(500))
                    await send(.loadRemote)
                }
                
            case let .favoriteButtonTapped(comic):
                comic.favorited.toggle()
                return .none
                
            case .remoteSearchButtonTapped:
                state.destination = .remoteSearchView(.init())
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

// MARK: - ContentViewState

extension UpdateFeature {
    enum ContentViewState {
        case failure
        case success
    }
}
