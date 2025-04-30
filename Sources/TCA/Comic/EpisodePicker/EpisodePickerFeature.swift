//
//  EpisodePickerFeature.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/16.
//

import ComposableArchitecture

@Reducer
struct EpisodePickerFeature {
    @ObservableState
    struct State: Equatable {
        let comic: Comic
        var epsideId: String
    }
    
    enum Action: Equatable, ViewAction {
        case view(UIAction)
    }
    
    var body: some ReducerOf<EpisodePickerFeature> {
        Reduce { state, action in
            switch action {
            case .view(let action):
                return handleViewAction(action, state: &state)
            }
        }
    }
}

// MARK: - ViewAction

extension EpisodePickerFeature {
    @CasePathable
    enum UIAction: Equatable {
        case episodeTapped(String)
    }
    
    func handleViewAction(_ action: UIAction, state: inout State) -> Effect<Action> {
        switch action {
        case .episodeTapped(let id):
            state.epsideId = id
            // callback to ReaderFeature
            return .none
        }
    }
}
