//
//  FavoriteView.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/12.
//

import ComposableArchitecture
import SwiftUI

struct FavoriteView: View {
    @Bindable var store: StoreOf<FavoriteFeature>
    
    var body: some View {
        contentView
            .searchable(text: $store.searchKey.sending(\.searchKeyChanged), placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("收藏列表")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $store.scope(state: \.destination?.detailView, action: \.destination.detailView)) { store in
                DetailView(store: store)
            }
            .onAppear {
                store.send(.loadCache)
            }
    }
}

// MARK: - Computed Properties

extension FavoriteView {
    @ViewBuilder
    var contentView: some View {
        switch store.contentViewState {
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
                store.send(.comicTapped(comic))
            } label: {
                Cell(comic: comic)
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
}

// MARK: - Functions

extension FavoriteView {
    @ViewBuilder
    func favoriteButton(comic: Comic) -> some View {
        Button("取消收藏") {
            store.send(.favoriteButtonTapped(comic))
        }
        .tint(Color.orange)
    }
}

// MARK: - Cell

extension FavoriteView {
    struct Cell: View {
        let comic: Comic
        let dateFormatter: DateFormatter = .init()
        
        var body: some View {
            contentView
        }
    }
}

// MARK: - Cell Computed Proeprties

import Kingfisher

extension FavoriteView.Cell {
    @ViewBuilder
    var contentView: some View {
        HStack(alignment: .top, spacing: 8) {
            cover
            
            VStack(alignment: .leading, spacing: 4) {
                title
                note
                watchDate
                lastUpdate
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    var cover: some View {
        KFImage(URL(string: "https:" + comic.cover))
            .resizable()
            .frame(width: 70, height: 90)
    }
    
    @ViewBuilder
    var title: some View {
        HStack(alignment: .top) {
            if comic.favorited {
                Image(systemName: "star.fill")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            Text(comic.title)
                .font(.headline)
        }
    }
    
    @ViewBuilder
    var note: some View {
        Text(comic.note)
            .font(.subheadline)
    }
    
    @ViewBuilder
    var watchDate: some View {
        Text(makeWatchText())
            .font(.footnote)
            .padding(.top, 8)
    }
    
    @ViewBuilder
    var lastUpdate: some View {
        HStack {
            Text(makeLastUpdateText())
                .font(.footnote)
            Text(comic.hasNew ? "New" : "")
                .font(.footnote)
                .bold()
                .foregroundStyle(.red)
        }
        .padding(.bottom, 12)
    }
}

// MARK: - Cell Functions

extension FavoriteView.Cell {
    func makeWatchText() -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        if let watchDate = comic.watchDate {
            return "觀看時間: " + dateFormatter.string(from: watchDate)
        }
        
        return "觀看時間: 未觀看"
    }
    
    func makeLastUpdateText() -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let lastUpdate = Date(timeIntervalSince1970: comic.lastUpdate)
        
        return "最後更新: " + dateFormatter.string(from: lastUpdate)
    }
}
