//
//  EpisodePickerView.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/16.
//

import ComposableArchitecture
import SwiftUI

@ViewAction(for: EpisodePickerFeature.self)
struct EpisodePickerView: View {
    let store: StoreOf<EpisodePickerFeature>
    
    var body: some View {
        contentView
            .navigationTitle("選取集數")
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - ViewBuilder

extension EpisodePickerView {
    @ViewBuilder
    var contentView: some View {
        List(store.comic.episodes ?? []) { episode in
            let selected = store.comic.watchedId == episode.id
            Button {
                send(.episodeTapped(episode.id))
            } label: {
                cell(episode: episode, selected: selected)
            }
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder
    func cell(episode: Comic.Episode, selected: Bool) -> some View {
        HStack {
            Text(episode.title)
            Spacer()
            Image(systemName: "checkmark")
                .bold()
                .foregroundStyle(.blue)
                .opacity(selected ? 1 : 0)
        }
        .frame(minHeight: 44)
    }
}
