//
//  RemoteSearchFeature.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/13.
//

import ComposableArchitecture
import AnyCodable
import WebParser

@Reducer
struct RemoteSearchFeature {
    @ObservableState
    struct State: Equatable {
        var comics: [Comic] = []
        var page = 1
        var isLoading = false
        var canLoadMore = true
        var searchKey = ""
        var isSearching: Bool = false
        
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

// MARK: - ViewAction

extension RemoteSearchFeature {
    @CasePathable
    enum UIAction: Equatable {
        case favoriteButtonTapped(Comic)
        case searchKeyChanged(String)
        case keyboardSearchButtonTapped
        case searchStateChanged(Bool)
        case comicTapped(Comic)
        case scrollToLoadMore
    }
    
    func handleViewAction(_ action: UIAction, state: inout State) -> Effect<Action> {
        switch action {
        case .favoriteButtonTapped(let comic):
            comic.favorited.toggle()
            return .none

        case .searchKeyChanged(let key):
            state.searchKey = key
            
            if key.isEmpty {
                state.comics.removeAll()
                state.page = 1
                state.canLoadMore = true
            }
            
            return .none

        case .keyboardSearchButtonTapped:
            return parseData(state: &state)

        case .searchStateChanged(let isSearching):
            state.isSearching = isSearching
            
            if isSearching {
                return .none
            }
            
            // 取消搜尋
            state.comics.removeAll()
            state.page = 1
            state.canLoadMore = true
            
            return .none

        case .comicTapped(let comic):
            state.navigation = .detailView(.init(comic: comic))
            return .none
            
        case .scrollToLoadMore:
            return parseData(state: &state)
        }
    }
}

// MARK: - DataAction

extension RemoteSearchFeature {
    @CasePathable
    enum DataAction: Equatable {
        case dataLoaded([Comic])
        case parseData
        case parseFailure
    }
    
    func handleDataAction(_ action: DataAction, state: inout State) -> Effect<Action> {
        switch action {
        case .dataLoaded(let comics):
            state.page += 1
            state.canLoadMore = comics.count >= 10
            LoadingActor.isLoading = false
            state.isLoading = false
            state.comics.append(contentsOf: comics)
            
            return .none

        case .parseData:
            return parseData(state: &state)

        case .parseFailure:
            LoadingActor.isLoading = false
            state.isLoading = false
            return .none
        }
    }
    
    func parseData(state: inout State) -> Effect<Action> {
        if !state.canLoadMore { return .none }
        if state.isLoading { return .none }
        if state.searchKey.isEmpty { return .none }
        
        state.isLoading = true
        LoadingActor.isLoading = true
        
        return .run {[keywords = state.searchKey, page = state.page] send in
            @Dependency(\.searchParser) var parser
            
            do {
                let data = try await parser.parser(keywords, page)
                let comics = await Storage.shared.insertOrUpdateComics(data.anyArray ?? [])
                await send(.dataAction(.dataLoaded(comics)))
            }
            catch {
                await send(.dataAction(.parseFailure))
            }
        }
    }
}

// MARK: - Navigation 跳轉

extension RemoteSearchFeature {
    @Reducer
    enum Navigation {
        case detailView(DetailFeature)
    }
}

extension RemoteSearchFeature.Navigation.State: Equatable {}
extension RemoteSearchFeature.Navigation.Action: Equatable {}

// MARK: - Dependency

@DependencyClient
struct SearchParser {
    let parser: @Sendable (_ keywords: String, _ page: Int) async throws -> AnyCodable
}

extension SearchParser: DependencyKey {
    static let liveValue: SearchParser = .init { keywords, page in
        removeWebKitFolder()
        let parser = await WebParser.Parser(parserConfiguration: .search(keywords: keywords, page: page))
        return try await parser.decodeResult(AnyCodable.self)
    }
}

extension DependencyValues {
    var searchParser: SearchParser {
        get { self[SearchParser.self] }
        set { self[SearchParser.self] = newValue }
    }
}
