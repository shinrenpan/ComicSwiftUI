//
//  RemoteSearchView.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/13.
//

import ComposableArchitecture
import SwiftUI

struct RemoteSearchView: View {
    @Bindable var store: StoreOf<RemoteSearchFeature>
    
    var body: some View {
        contentView
            .navigationTitle("線上搜尋")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarVisibility(.hidden, for: .tabBar)
            .searchable(text: $store.searchKey.sending(\.searchKeyChanged), placement: .navigationBarDrawer(displayMode: .always))
            .onSubmit(of: .search) {
                store.send(.loadData)
            }
            .navigationDestination(item: $store.scope(state: \.destination?.detailView, action: \.destination.detailView)) { store in
                DetailView(store: store)
            }
    }
}

// MARK: - Computed Properties

extension RemoteSearchView {
    @ViewBuilder
    var contentView: some View {
        List {
            ForEach(store.comics.indices, id: \.self) { index in
                let comic = store.comics[index]
                
                Button {
                    store.send(.comicTapped(comic))
                } label: {
                    UpdateView.Cell(comic: comic)
                }
                .swipeActions(edge: .trailing) {
                    favoriteButton(comic: comic)
                }
                .swipeActions(edge: .leading) {
                    favoriteButton(comic: comic)
                }
                .onAppear {
                    if store.canLoadMore, index == store.comics.count - 1 {
                        store.send(.loadMore)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Functions

extension RemoteSearchView {
    @ViewBuilder
    func favoriteButton(comic: Comic) -> some View {
        Button(comic.favorited ? "取消收藏" : "加入收藏") {
            store.send(.favoriteButtonTapped(comic))
        }
        .tint(comic.favorited ? Color.orange : Color.blue)
    }
}
