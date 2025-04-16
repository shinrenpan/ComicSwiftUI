//
//  ReaderFeature.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/13.
//

import ComposableArchitecture
import AnyCodable
import SwiftUICore

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
        @Presents var sheet: Router.Sheet.State?
    }
    
    enum Action: Equatable {
        case firstLoad
        case loadData
        case loadDataFailure
        case loadDataSuccess(_ data: AnyCodable, hasPrev: Bool, hasNext: Bool)
        case favoriteButtonTapped
        case directionButtonTapped
        case prevButtonTapped
        case nextButtonTapped
        case episodeIdChanged(String)
        case imageTapped
        case episodePickerTapped
        case sheet((PresentationAction<Router.Sheet.Action>))
    }
    
    @Dependency(\.comicParser) var parser
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .firstLoad:
                if !state.firstLoad {
                    return .none
                }
                
                return .run { send in
                    await send(.loadData)
                }
                
            case .loadData:
                LoadingActor.isLoading = true
                
                return .run { [comicId = state.comic.id, episodeId = state.episodeId] send in
                    do {
                        let data = try await parser.images(comicId: comicId, episodeId: episodeId)
                        let hasPrev = await prevEpisodeId(comicId: comicId, currentId: episodeId) != nil
                        let hasNext = await nextEpisodeId(comicId: comicId, currentId: episodeId) != nil
                        await send(.loadDataSuccess(data, hasPrev: hasPrev, hasNext: hasNext))
                    }
                    catch {
                        await send(.loadDataFailure)
                    }
                }
                
            case .loadDataFailure:
                LoadingActor.isLoading = false
                return .none
                
            case let .loadDataSuccess(data, hasPrev, hasNext):
                state.images = .init(uniqueElements: convertToImages(data))
                state.title = state.comic.episodes?.first(where: { $0.id == state.episodeId })?.title ?? ""
                state.hasPrev = hasPrev
                state.hasNext = hasNext
                state.comic.watchedId = state.episodeId
                state.comic.watchDate = .now
                state.comic.updateHasNew()
                LoadingActor.isLoading = false
                
                return .none
                
            case .favoriteButtonTapped:
                state.comic.favorited.toggle()
                return .none
                
            case .directionButtonTapped:
                state.isHorizontal.toggle()
                return .none
                
            case .prevButtonTapped:
                return .run {[comicId = state.comic.id, epidoseId = state.episodeId] send in
                    if let prevId = await prevEpisodeId(comicId: comicId, currentId: epidoseId) {
                        await send(.episodeIdChanged(prevId))
                    }
                }
                
            case .nextButtonTapped:
                return .run {[comicId = state.comic.id, epidoseId = state.episodeId] send in
                    if let nextId = await nextEpisodeId(comicId: comicId, currentId: epidoseId) {
                        await send(.episodeIdChanged(nextId))
                    }
                }
                
            case let .episodeIdChanged(id):
                state.episodeId = id
                state.images = []
                return .send(.loadData)
                
            case .imageTapped:
                state.showBar.toggle()
                return .none
                
            case .episodePickerTapped:
                state.sheet = .episodePicker(.init(comic: state.comic, epsideId: state.episodeId))
                return .none
                
            case .sheet(.presented(.episodePicker(.episodeTapped(let id)))):
                state.sheet = nil
                
                if state.episodeId == id {
                    return .none
                }
                
                return .send(.episodeIdChanged(id))
                
            case .sheet:
                return .none
            }
        }
        .ifLet(\.$sheet, action: \.sheet)
    }
}

// MARK: - Image

extension ReaderFeature {
    struct Image: Identifiable, Equatable {
        let id: String
        let uri: String
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
