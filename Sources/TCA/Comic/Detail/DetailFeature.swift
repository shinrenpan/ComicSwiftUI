//
//  DetailFeature.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/12.
//

import ComposableArchitecture
import AnyCodable
import WebParser

@Reducer
struct DetailFeature {
    @ObservableState
    struct State: Equatable {
        let comic: Comic
        var firstLoad = true
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

extension DetailFeature {
    enum ViewState {
        case failure
        case success
    }
}

// MARK: - ViewAction

extension DetailFeature {
    @CasePathable
    enum UIAction: Equatable {
        case onAppear
        case retryButtonTapped
        case episodeTapped(String)
        case favoriteButtonTapped
    }
    
    func handleViewAction(_ action: UIAction, state: inout State) -> Effect<Action> {
        switch action {
        case .onAppear:
            state.comic.episodes?.sort { $0.index < $1.index }
            
            if !state.firstLoad {
                return .none
            }
            
            state.firstLoad = false
            
            return .run { send in
                @Dependency(\.continuousClock) var clock
                try await clock.sleep(for: .milliseconds(500))
                await send(.dataAction(.parseData))
            }
            
        case .retryButtonTapped:
            return parseData(state: &state)
            
        case .episodeTapped(let id):
            state.navigation =  .readerView(.init(comic: state.comic, episodeId: id))
            return .none
            
        case .favoriteButtonTapped:
            state.comic.favorited.toggle()
            return .none
        }
    }
}

// MARK: - Data Action

extension DetailFeature {
    @CasePathable
    enum DataAction: Equatable {
        case parseData
        case parseSuccess(AnyCodable)
        case parseFailure
    }
    
    func handleDataAction(_ action: DataAction, state: inout State) -> Effect<Action> {
        switch action {
        case .parseData:
            return parseData(state: &state)
            
        case .parseSuccess(let data):
            LoadingActor.isLoading = false
            state.comic.detail?.author = data["author"].string ?? ""
            state.comic.detail?.desc = data["desc"].string ?? ""
            let episodes = convertToEpisodes(data["episodes"].anyArray ?? [])
            state.comic.episodes =  episodes.sorted(by: { $0.index < $1.index })
            state.viewState = episodes.isEmpty ? .failure : .success
            return .none
            
        case .parseFailure:
            LoadingActor.isLoading = false
            state.viewState = .failure
            return .none
        }
    }
    
    func parseData(state: inout State) -> Effect<Action> {
        LoadingActor.isLoading = true
        
        return .run { [comicId = state.comic.id] send in
            @Dependency(\.detailParser) var detailParser
            
            do {
                let data = try await detailParser.parse(comicId)
                await send(.dataAction(.parseSuccess(data)))
            }
            catch {
                await send(.dataAction(.parseFailure))
            }
        }
    }
}

// MARK: - Navigation 跳轉

extension DetailFeature {
    @Reducer
    enum Navigation {
        case readerView(ReaderFeature)
    }
}

extension DetailFeature.Navigation.State: Equatable {}
extension DetailFeature.Navigation.Action: Equatable {}

// MARK: - Dependency

@DependencyClient
struct DetailParser {
    let parse: @Sendable (_ comicId: String) async throws -> AnyCodable
}

extension DetailParser: DependencyKey {
    static let liveValue: DetailParser = .init { comicId in
        removeWebKitFolder()
        let parser = await WebParser.Parser(parserConfiguration: .detail(comicId: comicId))
        return try await parser.decodeResult(AnyCodable.self)
    }
}

extension DependencyValues {
    var detailParser: DetailParser {
        get { self[DetailParser.self] }
        set { self[DetailParser.self] = newValue }
    }
}

// MARK: - Functions

extension DetailFeature {
    func convertToEpisodes(_ array: [AnyCodable]) -> [Comic.Episode] {
        return array.compactMap {
            guard let id = $0["id"].string, !id.isEmpty else {
                return nil
            }
            
            guard let title = $0["title"].string, !title.isEmpty else {
                return nil
            }
            
            guard let index = $0["index"].int else {
                return nil
            }
            
            return .init(id: id, index: index, title: title)
        }
    }
}
