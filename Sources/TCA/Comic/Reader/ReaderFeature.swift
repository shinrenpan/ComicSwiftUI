//
//  ReaderFeature.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/13.
//

import ComposableArchitecture
import AnyCodable
import WebParser

@Reducer
struct ReaderFeature {
    @ObservableState
    struct State: Equatable {
        var images: IdentifiedArrayOf<Image> = []
        let comic: Comic
        var episodeId: String
        var firstLoad = true
        var isHorizontal = true
        var showBar = true
        var title = ""
        var hasNext = false
        var hasPrev = false
        
        @Presents var sheet: Sheet.State?
    }
    
    enum Action: Equatable, ViewAction {
        case view(UIAction)
        case dataAction(DataAction)
        
        case sheetAction(PresentationAction<Sheet.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(let action):
                return handleViewAction(action, state: &state)
            
            case .dataAction(let action):
                return handleDataAction(action, state: &state)
                
            case .sheetAction(let action):
                return handleSheetAction(action, state: &state)
            }
        }
        .ifLet(\.$sheet, action: \.sheetAction)
    }
}

// MARK: - ViewAction

extension ReaderFeature {
    @CasePathable
    enum UIAction {
        case onAppear
        case readerTapped
        case prevButtonTapped
        case nextButtonTapped
        case pickerButtonTapped
        case favoriteButtonTapped
        case directionButtonTapped
    }
    
    func handleViewAction(_ action: UIAction, state: inout State) -> Effect<Action> {
        switch action {
        case .onAppear:
            if !state.firstLoad { return .none }
            state.firstLoad = false
            return .send(.dataAction(.parseData))
            
        case .readerTapped:
            state.showBar.toggle()
            return .none
            
        case .prevButtonTapped:
            return .run {[comicId = state.comic.id, epidoseId = state.episodeId] send in
                if let prevId = await prevEpisodeId(comicId: comicId, currentId: epidoseId) {
                    await send(.dataAction(.episodeIdChanged(prevId)))
                }
            }
            
        case .nextButtonTapped:
            return .run {[comicId = state.comic.id, epidoseId = state.episodeId] send in
                if let nextId = await nextEpisodeId(comicId: comicId, currentId: epidoseId) {
                    await send(.dataAction(.episodeIdChanged(nextId)))
                }
            }
            
        case .pickerButtonTapped:
            state.sheet = .episodePicker(.init(comic: state.comic, epsideId: state.episodeId))
            return .none
            
        case .favoriteButtonTapped:
            state.comic.favorited.toggle()
            return .none
            
        case .directionButtonTapped:
            state.isHorizontal.toggle()
            return .none
        }
    }
}

// MARK: - DataAction

extension ReaderFeature {
    struct Image: Identifiable, Equatable {
        let id: String
        let uri: String
    }
    
    @CasePathable
    enum DataAction: Equatable {
        case parseData
        case parseSuccess(AnyCodable, hasPrev: Bool, hasNext: Bool)
        case parseFailure
        case episodeIdChanged(String)
    }
    
    func handleDataAction(_ action: DataAction, state: inout State) -> Effect<Action> {
        switch action {
        case .parseData:
            LoadingActor.isLoading = true
            
            return .run { [comicId = state.comic.id, episodeId = state.episodeId] send in
                @Dependency(\.readerParser) var parser
                
                do {
                    let data = try await parser.parse(comicId: comicId, episodeId: episodeId)
                    let hasPrev = await prevEpisodeId(comicId: comicId, currentId: episodeId) != nil
                    let hasNext = await nextEpisodeId(comicId: comicId, currentId: episodeId) != nil
                    await send(.dataAction(.parseSuccess(data, hasPrev: hasPrev, hasNext: hasNext)))
                }
                catch {
                    await send(.dataAction(.parseFailure))
                }
            }
            
        case let .parseSuccess(data, hasPrev, hasNext):
            state.images = .init(uniqueElements: convertToImages(data))
            state.title = state.comic.episodes?.first(where: { $0.id == state.episodeId })?.title ?? ""
            state.hasPrev = hasPrev
            state.hasNext = hasNext
            state.comic.watchedId = state.episodeId
            state.comic.watchDate = .now
            state.comic.updateHasNew()
            LoadingActor.isLoading = false
            return .none
            
        case .parseFailure:
            LoadingActor.isLoading = false
            return .none
            
        case .episodeIdChanged(let id):
            if state.episodeId == id { return .none }
            
            state.episodeId = id
            state.images = []
            return .send(.dataAction(.parseData))
        }
    }
}

// MARK: - Sheet

extension ReaderFeature {
    @Reducer
    enum Sheet {
        case episodePicker(EpisodePickerFeature)
    }
    
    func handleSheetAction(_ action: PresentationAction<Sheet.Action>, state: inout State) -> Effect<Action> {
        switch action {
        case .presented(.episodePicker(.view(.episodeTapped(let id)))):
            state.sheet = nil
            return .send(.dataAction(.episodeIdChanged(id)))
            
        default:
            return .none
        }
    }
}

extension ReaderFeature.Sheet.State: Equatable {}
extension ReaderFeature.Sheet.Action: Equatable {}

// MARK: - Dependency

@DependencyClient
struct ReaderParser {
    var parse: @Sendable (_ comicId: String, _ episodeId: String) async throws -> AnyCodable
}

extension ReaderParser: DependencyKey {
    static let liveValue: ReaderParser = .init { comicId, episodeId in
        removeWebKitFolder()
        let parser = await WebParser.Parser(parserConfiguration: .images(comicId: comicId, episodeId: episodeId))
        return try await parser.decodeResult(AnyCodable.self)
    }
}

extension DependencyValues {
    var readerParser: ReaderParser {
        get { self[ReaderParser.self] }
        set { self[ReaderParser.self] = newValue }
    }
}

// MARK: - Functions

extension ReaderFeature {
    func convertToImages(_ data: AnyCodable) -> [ReaderFeature.Image] {
        data.anyArray?.compactMap {
            guard let uri = $0["uri"].string, !uri.isEmpty else {
                return nil
            }
            
            guard let uriDecode = uri.removingPercentEncoding else {
                return nil
            }
            
            return .init(id: uriDecode, uri: uriDecode)
        } ?? []
    }
    
    func prevEpisodeId(comicId: String, currentId: String) async -> String? {
        let episodes = await Storage.shared.getEpisodes(comicId: comicId)
        
        guard let currentIndex = episodes.firstIndex(where: { $0.id == currentId }) else {
            return nil
        }
        
        return episodes.first(where: { $0.index == currentIndex + 1 })?.id
    }
    
    func nextEpisodeId(comicId: String, currentId: String) async -> String? {
        let episodes = await Storage.shared.getEpisodes(comicId: comicId)
        
        guard let currentIndex = episodes.firstIndex(where: { $0.id == currentId }) else {
            return nil
        }
        
        return episodes.first(where: { $0.index == currentIndex - 1 })?.id
    }
}

