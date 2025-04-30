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
        var isSearching: Bool = false
        var viewState: ViewState = .success
        
        @Presents var navigation: Navigation.State?
    }
    
    enum Action: Equatable, ViewAction {
        case view(UIAction)
        case dataAction(DataAction)
        
        case navigationAction(PresentationAction<Navigation.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(let action):
                return handleViewAction(action, state: &state)
                
            case .dataAction(let action):
                return handleDataAction(action, state: &state)
                
            case .navigationAction:
                return .none
            }
        }
        .ifLet(\.$navigation, action: \.navigationAction)
    }
}

// MARK: - ViewState

extension FavoriteFeature {
    enum ViewState {
        case empty
        case success
    }
}

// MARK: - ViewAction

extension FavoriteFeature {
    @CasePathable
    enum UIAction: Equatable {
        case onAppear
        case favoriteButtonTapped(Comic)
        case searchKeyChanged(String)
        case keyboardSearchButtonTapped
        case searchStateChanged(Bool)
        case comicTapped(Comic)
    }
    
    func handleViewAction(_ action: UIAction, state: inout State) -> Effect<Action> {
        switch action {
        case .onAppear:
            return onAppear(state: &state)
            
        case .favoriteButtonTapped(let comic):
            comic.favorited = false
            state.comics.removeAll(where: { $0.id == comic.id })
            state.viewState = state.comics.isEmpty ? .empty : .success
            return .none
            
        case .searchKeyChanged(let key):
            state.searchKey = key
            return .none
            
        case .keyboardSearchButtonTapped:
            return onAppear(state: &state)
            
        case .searchStateChanged(let isSearching):
            state.isSearching = isSearching
            
            if isSearching {
                return .none
            }
            
            return onAppear(state: &state)
            
        case .comicTapped(let comic):
            state.navigation = .detailView(.init(comic: comic))
            return .none
        }
    }
    
    func onAppear(state: inout State) -> Effect<Action> {
        return .run { [keywords = state.searchKey] send in
            let comics = await Storage.shared.getFavorites(keywords: keywords)
            await send(.dataAction(.dataLoaded(comics)))
        }
    }
}

// MARK: - DataAction

extension FavoriteFeature {
    @CasePathable
    enum DataAction: Equatable {
        case dataLoaded([Comic])
    }
    
    func handleDataAction(_ action: DataAction, state: inout State) -> Effect<Action> {
        switch action {
        case .dataLoaded(let comics):
            state.comics = comics
            state.viewState = comics.isEmpty ? .empty : .success
            return .none
        }
    }
}

// MARK: - Navigation 跳轉

extension FavoriteFeature {
    @Reducer
    enum Navigation {
        case detailView(DetailFeature)
    }
}

extension FavoriteFeature.Navigation.State: Equatable {}
extension FavoriteFeature.Navigation.Action: Equatable {}
