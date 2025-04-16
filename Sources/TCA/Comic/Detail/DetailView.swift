//
//  DetailView.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/12.
//

import ComposableArchitecture
import SwiftUI

struct DetailView: View {
    @Bindable var store: StoreOf<DetailFeature>
    
    var body: some View {
        content
            .navigationTitle("詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarVisibility(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    favoriteButton
                }
            }
            .navigationDestination(item: $store.scope(state: \.destination?.readerView, action: \.destination.readerView)) { store in
                ReaderView(store: store)
            }
            .onAppear {
                store.send(.loadRemote)
            }
    }
}

// MARK: - Computed Propeties

extension DetailView {
    @ViewBuilder
    var content: some View {
        switch store.contentViewState {
        case .failure:
            ContentUnavailableView {
                Button("重試") {
                    store.send(.reloadButtonTappen)
                }
            }
            
        case .success:
            VStack {
                Header(comic: store.comic)
                list
            }
        }
    }
    
    @ViewBuilder
    var list: some View {
        List(store.comic.episodes ?? []) { episode in
            let selected = store.comic.watchedId == episode.id
            Button {
                store.send(.episodeTapped(episode.id))
            } label: {
                cell(episode: episode, selected: selected)
            }
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder
    var favoriteButton: some View {
        Button {
            store.send(.favoriteButtonTapped)
        } label: {
            store.comic.favorited ? Image(systemName: "star.fill") : Image(systemName: "star")
        }
    }
}

// MARK: - Functions

extension DetailView {
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

// MARK: - Header

extension DetailView {
    struct Header: View {
        let comic: Comic
        @State var lineLimit = 4
        
        var body: some View {
            HStack(alignment: .top, spacing: 8) {
                cover
                
                VStack(alignment: .leading, spacing: 4) {
                    title
                    author
                    description
                }
                
                Spacer()
            }
            .padding(16)
        }
    }
}

import Kingfisher

// MARK: - Header Computed Properties

extension DetailView.Header {
    @ViewBuilder
    var cover: some View {
        KFImage(URL(string: "https:" + comic.cover))
            .resizable()
            .frame(width: 70, height: 90)
    }
    
    @ViewBuilder
    var title: some View {
        Text(comic.title)
            .font(.headline)
            .lineLimit(2)
    }
    
    @ViewBuilder
    var author: some View {
        Text(comic.detail?.author ?? "")
            .font(.subheadline)
    }
    
    @ViewBuilder
    var description: some View {
        Text(comic.detail?.desc ?? "")
            .font(.subheadline)
            .lineLimit(lineLimit)
            .padding(.top, 8)
            .onTapGesture {
                lineLimit = lineLimit > 1 ? 1 : 4
            }
    }
}
