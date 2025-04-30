//
//  FavoriteView.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/12.
//

import ComposableArchitecture
import SwiftUI

@ViewAction(for: FavoriteFeature.self)
struct FavoriteView: View {
    @Bindable var store: StoreOf<FavoriteFeature>
    
    var body: some View {
        contentView
            .searchable(
                text: $store.searchKey.sending(\.view.searchKeyChanged),
                isPresented: $store.isSearching.sending(\.view.searchStateChanged),
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .navigationTitle("收藏列表")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(
                item: $store.scope(state: \.navigation?.detailView, action: \.navigationAction.detailView)
            ) { store in
                DetailView(store: store)
            }
            .onAppear {
                send(.onAppear)
            }
            .onSubmit(of: .search) {
                send(.keyboardSearchButtonTapped)
            }
    }
}

// MARK: - ViewBuilder

extension FavoriteView {
    @ViewBuilder
    var contentView: some View {
        switch store.viewState {
        case .empty:
            ContentUnavailableView {
                Text("空空如也")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
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
                FavoriteCell(comic: comic)
            }
            .swipeActions(edge: .trailing) {
                favoriteButton(comic: comic)
            }
            .swipeActions(edge: .leading) {
                favoriteButton(comic: comic)
            }
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder
    func favoriteButton(comic: Comic) -> some View {
        Button("取消收藏") {
            withAnimation {
                _ = send(.favoriteButtonTapped(comic))
            }
        }
        .tint(Color.orange)
    }
}
