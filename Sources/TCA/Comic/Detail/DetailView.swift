//
//  DetailView.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/12.
//

import ComposableArchitecture
import SwiftUI

@ViewAction(for: DetailFeature.self)
struct DetailView: View {
    @Bindable var store: StoreOf<DetailFeature>
    
    var body: some View {
        contentView
            .navigationTitle("詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarVisibility(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    favoriteButton
                }
            }
            .navigationDestination(
                item: $store.scope(state: \.navigation?.readerView, action: \.navigationAction.readerView)
            ) { store in
                ReaderView(store: store)
            }
            .onAppear {
                send(.onAppear)
            }
    }
}

// MARK: - ViewBuilder

extension DetailView {
    @ViewBuilder
    var contentView: some View {
        switch store.viewState {
        case .failure:
            ContentUnavailableView {
                Button("重試") {
                    send(.retryButtonTapped)
                }
            }
            
        case .success:
            VStack {
                DetailHeader(comic: store.comic)
                list
            }
        }
    }
    
    @ViewBuilder
    var list: some View {
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
    var favoriteButton: some View {
        Button {
            send(.favoriteButtonTapped)
        } label: {
            store.comic.favorited ? Image(systemName: "star.fill") : Image(systemName: "star")
        }
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
