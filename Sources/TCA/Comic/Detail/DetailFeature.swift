//
//  DetailFeature.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/12.
//

import ComposableArchitecture
import AnyCodable

@Reducer
struct DetailFeature {
    @ObservableState
    struct State: Equatable {
        let comic: Comic
        var firstLoad = true
        var contentViewState: ContentViewState = .success
        @Presents var destination: Router.Navigation.State?
        
        init(comic: Comic) {
            comic.episodes?.sort { $0.index < $1.index }
            self.comic = comic
        }
    }
    
    enum Action: Equatable {
        case loadRemote
        case loadRemoteFailure
        case loadRemoteSuccess(AnyCodable)
        case comicUpdated(author: String, desc: String, episodes: [Comic.Episode])
        case favoriteButtonTapped
        case reloadButtonTappen
        case episodeTapped(Comic.Episode.ID)
        case destination((PresentationAction<Router.Navigation.Action>))
    }
    
    @Dependency(\.comicParser) var parser
    @Dependency(\.continuousClock) var clock
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadRemote:
                if !state.firstLoad {
                    return .none
                }
                
                state.firstLoad = false
                
                return .run { [comicId = state.comic.id] send in
                    try await clock.sleep(for: .milliseconds(500))
                    LoadingActor.isLoading = true
                    
                    do {
                        let data = try await parser.detail(comicId: comicId)
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
                    let author = data["author"].string ?? ""
                    let desc = data["desc"].string ?? ""
                    let episodes = convertToEpisodes(data["episodes"].anyArray ?? [])
                    await send(.comicUpdated(author: author, desc: desc, episodes: episodes))
                }
                
            case let .comicUpdated(author, desc, episodes):
                LoadingActor.isLoading = false
                state.contentViewState = episodes.isEmpty ? .failure : .success
                state.comic.detail?.author = author
                state.comic.detail?.desc = desc
                state.comic.episodes = episodes
                return .none
                
            case .favoriteButtonTapped:
                state.comic.favorited.toggle()
                return .none
            
            case .reloadButtonTappen:
                return .run { [comicId = state.comic.id] send in
                    LoadingActor.isLoading = true
                    
                    do {
                        let data = try await parser.detail(comicId: comicId)
                        await send(.loadRemoteSuccess(data))
                    }
                    catch {
                        await send(.loadRemoteFailure)
                    }
                }
                
            case let .episodeTapped(id):
                state.destination = .readerView(.init(comic: state.comic, episodeId: id))
                return .none
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
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

// MARK: - ContentViewState

extension DetailFeature {
    enum ContentViewState {
        case failure
        case success
    }
}

