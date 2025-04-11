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
        let epsideId: String
    }
    
    enum Action: Equatable {
        case episodeTapped(String)
    }
    
    var body: some ReducerOf<EpisodePickerFeature> {
        Reduce { state, action in
            switch action {
            case .episodeTapped:
                return .none
            }
        }
    }
}
