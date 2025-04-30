//
//  RemoteSearchView.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/13.
//

import ComposableArchitecture
import SwiftUI

@ViewAction(for: RemoteSearchFeature.self)
struct RemoteSearchView: View {
    @Bindable var store: StoreOf<RemoteSearchFeature>
    
    var body: some View {
        contentView
            .navigationTitle("線上搜尋")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarVisibility(.hidden, for: .tabBar)
            .searchable(
                text: $store.searchKey.sending(\.view.searchKeyChanged),
                isPresented: $store.isSearching.sending(\.view.searchStateChanged),
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .onSubmit(of: .search) {
                send(.keyboardSearchButtonTapped)
            }
            .navigationDestination(item: $store.scope(state: \.navigation?.detailView, action: \.navigationAction.detailView)) { store in
                DetailView(store: store)
            }
    }
}

// MARK: - ViewBuilder

extension RemoteSearchView {
    @ViewBuilder
    var contentView: some View {
        List {
            ForEach(store.comics.indices, id: \.self) { index in
                let comic = store.comics[index]
                
                Button {
                    send(.comicTapped(comic))
                } label: {
                    RemoteSearchCell(comic: comic)
                }
                .swipeActions(edge: .trailing) {
                    favoriteButton(comic: comic)
                }
                .swipeActions(edge: .leading) {
                    favoriteButton(comic: comic)
                }
                .onAppear {
                    if store.canLoadMore, index == store.comics.count - 1 {
                        send(.scrollToLoadMore)
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    func favoriteButton(comic: Comic) -> some View {
        Button(comic.favorited ? "取消收藏" : "加入收藏") {
            send(.favoriteButtonTapped(comic))
        }
        .tint(comic.favorited ? Color.orange : Color.blue)
    }
}
