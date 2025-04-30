//
//  HistoryView.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/12.
//

import ComposableArchitecture
import SwiftUI

@ViewAction(for: HistoryFeature.self)
struct HistoryView: View {
    @Bindable var store: StoreOf<HistoryFeature>
    
    var body: some View {
        contentView
            .searchable(
                text: $store.searchKey.sending(\.view.searchKeyChanged),
                isPresented: $store.isSearching.sending(\.view.searchStateChanged),
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .navigationTitle("觀看紀錄")
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

extension HistoryView {
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
                HistoryCell(comic: comic)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                favoriteButton(comic: comic)
                removeButton(comic: comic)
            }
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                favoriteButton(comic: comic)
                removeButton(comic: comic)
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
    
    @ViewBuilder
    func removeButton(comic: Comic) -> some View {
        Button("移除紀錄") {
            withAnimation {
                _ = send(.removeButtonTapped(comic))
            }
        }
        .tint(.red)
    }
}
