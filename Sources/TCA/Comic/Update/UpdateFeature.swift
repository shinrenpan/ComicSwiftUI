//
//  UpdateFeature.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/12.
//

import ComposableArchitecture
import AnyCodable
import WebParser

@Reducer
struct UpdateFeature {
    @ObservableState
    struct State: Equatable {
        var comics: [Comic] = []
        var firstLoad = true
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

extension UpdateFeature {
    enum ViewState {
        case failure
        case success
    }
}

// MARK: - UIAction

extension UpdateFeature {
    @CasePathable
    enum UIAction: Equatable {
        case onAppear
        case retryButtonTapped
        case pullToRefresh
        case favoriteButtonTapped(Comic)
        case searchButtonTapped
        case searchKeyChanged(String)
        case keyboardSearchButtonTapped
        case searchStateChanged(Bool)
        case comicTapped(Comic)
    }
    
    func handleViewAction(_ action: UIAction, state: inout State) -> Effect<Action> {
        switch action {
        case .onAppear:
            if !state.firstLoad { return .none }
            
            state.firstLoad = false
            
            return .run { send in
                let comics = await Storage.shared.getAll()
                await send(.dataAction(.dataLoaded(comics)))
                @Dependency(\.continuousClock) var clock
                try await clock.sleep(for: .milliseconds(500))
                await send(.dataAction(.parseData))
            }

        case .retryButtonTapped:
            return parseData()

        case .pullToRefresh:
            state.isSearching = false // 會自動將 searchKey 變為 ""
            return parseData()

        case .favoriteButtonTapped(let comic):
            comic.favorited.toggle()
            return .none

        case .searchButtonTapped:
            state.navigation = .remoteSearchView(.init())
            return .none

        case .searchKeyChanged(let key):
            state.searchKey = key
            return .none

        case .keyboardSearchButtonTapped:
            return .run { [searchKey = state.searchKey] send in
                let comics: [Comic] = await Storage.shared.getAll(keywords: searchKey)
                await send(.dataAction(.dataSearched(comics)))
            }

        case .searchStateChanged(let isSearching):
            state.isSearching = isSearching
            
            if isSearching {
                return .none
            }
            
            // 取消搜尋
            return .run { send in
                let comics: [Comic] = await Storage.shared.getAll()
                await send(.dataAction(.dataLoaded(comics)))
            }

        case .comicTapped(let comic):
            state.navigation = .detailView(.init(comic: comic))
            return .none
        }
    }
}

// MARK: - DataAction

extension UpdateFeature {
    @CasePathable
    enum DataAction: Equatable {
        case dataLoaded([Comic])
        case parseData
        case parseFailure
        case dataSearched([Comic])
    }
    
    func handleDataAction(_ action: DataAction, state: inout State) -> Effect<Action> {
        switch action {
        case .dataLoaded(let comics):
            state.comics = comics
            state.viewState = comics.isEmpty ? .failure : .success
            LoadingActor.isLoading = false
            return .none

        case .parseData:
            return parseData()

        case .parseFailure:
            LoadingActor.isLoading = false
            state.viewState = .failure
            return .none

        case .dataSearched(let comics):
            state.comics = comics
            return .none
        }
    }
    
    func parseData() -> Effect<Action> {
        LoadingActor.isLoading = true
        
        return .run { send in
            @Dependency(\.updateParser) var parser
            
            do {
                let data = try await parser.parse()
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

extension UpdateFeature {
    @Reducer
    enum Navigation {
        case remoteSearchView(RemoteSearchFeature)
        case detailView(DetailFeature)
    }
}

extension UpdateFeature.Navigation.State: Equatable {}
extension UpdateFeature.Navigation.Action: Equatable {}

// MARK: - Dependency

@DependencyClient
struct UpdateParser {
    let parse: @Sendable () async throws -> AnyCodable
}

extension UpdateParser: DependencyKey {
    static let liveValue: UpdateParser = .init {
        removeWebKitFolder()
        let parser = await WebParser.Parser(parserConfiguration: .update())
        return try await parser.decodeResult(AnyCodable.self)
    }
}

extension DependencyValues {
    var updateParser: UpdateParser {
        get { self[UpdateParser.self] }
        set { self[UpdateParser.self] = newValue }
    }
}
