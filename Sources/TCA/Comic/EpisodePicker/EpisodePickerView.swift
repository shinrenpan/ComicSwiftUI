//
//  EpisodePickerView.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/16.
//

import ComposableArchitecture
import SwiftUI

struct EpisodePickerView: View {
    let store: StoreOf<EpisodePickerFeature>
    
    var body: some View {
        NavigationStack {
            List(store.comic.episodes ?? []) { episode in
                let selected = store.comic.watchedId == episode.id
                Button {
                    store.send(.episodeTapped(episode.id))
                } label: {
                    cell(episode: episode, selected: selected)
                }
            }
            .navigationTitle("選取集數")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.plain)
        }
    }
}

// MARK: - Functions

extension EpisodePickerView {
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
