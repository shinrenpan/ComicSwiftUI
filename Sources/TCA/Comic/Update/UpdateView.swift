//
//  UpdateView.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/12.
//

import ComposableArchitecture
import SwiftUI

@ViewAction(for: UpdateFeature.self)
struct UpdateView: View {
    @Bindable var store: StoreOf<UpdateFeature>
    
    var body: some View {
        contentView
            .navigationTitle("更新列表")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("線上搜尋") {
                        send(.searchButtonTapped)
                    }
                }
            }
            .onAppear {
                send(.onAppear)
            }
            .onSubmit(of: .search) {
                send(.keyboardSearchButtonTapped)
            }
            .navigationDestination(
                item: $store.scope(state: \.navigation?.detailView, action: \.navigationAction.detailView)
            ) { store in
                DetailView(store: store)
            }
            .navigationDestination(
                item: $store.scope(state: \.navigation?.remoteSearchView, action: \.navigationAction.remoteSearchView)
            ) { store in
                RemoteSearchView(store: store)
            }
    }
}

// MARK: - ViewBuilder

extension UpdateView {
    @ViewBuilder
    var contentView: some View {
        switch store.viewState {
        case .failure:
            ContentUnavailableView {
                Button("Retry") {
                    send(.retryButtonTapped)
                }
            }
            
        case .success:
            list
        }
    }
    
    @ViewBuilder
    var list: some View {
        List(store.comics) { comic in
            Button {
                send(.comicTapped(comic))
            } label: {
                UpdateCell(comic: comic)
            }
            .swipeActions(edge: .trailing) {
                favoriteButton(comic: comic)
            }
            .swipeActions(edge: .leading) {
                favoriteButton(comic: comic)
            }
        }
        .listStyle(.plain)
        .searchable(
            text: $store.searchKey.sending(\.view.searchKeyChanged),
            isPresented: $store.isSearching.sending(\.view.searchStateChanged),
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .refreshable {
            send(.pullToRefresh)
        }
    }
    
    @ViewBuilder
    func favoriteButton(comic: Comic) -> some View {
        Button(comic.favorited ? "取消收藏" : "加入收藏") {
            send(.favoriteButtonTapped(comic))
        }
        .tint(comic.favorited ? Color.orange : Color.blue)
    }
}
