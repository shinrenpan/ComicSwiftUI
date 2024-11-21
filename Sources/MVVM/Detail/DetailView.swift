//
//  DetailView.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import Kingfisher
import UIKit
import SwiftUI

struct DetailView: View {
    @State private var viewModel: ViewModel
    @State private var lineLimit = 4
    
    init(comicId: String) {
        self.viewModel = .init(comicId: comicId)
    }
    
    var body: some View {
        ZStack {
            VStack {
                header(comic: viewModel.comic)
                list
            }
            
            if viewModel.isLoading {
                loadingView
            }
        }
        .navigationTitle("詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                favoriteButton
            }
        }
        .onAppear {
            viewModel.doAction(.loadData)
        }
    }
}

// MARK: - Computed Properties

private extension DetailView {
    var list: some View {
        List {
            ForEach(viewModel.comic.episodes, id: \.id) { episode in
                cellRow(episode: episode)
            }
        }
        .animation(.default, value: UUID())
        .tint(.clear) // https://stackoverflow.com/a/74909831
        .listStyle(.plain)
        .refreshable {
            viewModel.doAction(.loadRemote)
        }
    }
    
    var loadingView: some View {
        ProgressView() {
            Text("Loading...")
                .font(.largeTitle)
                .foregroundStyle(.white)
        }
        .controlSize(.extraLarge)
        .tint(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.6))
    }
    
    var favoriteButton: some View {
        Button {
            viewModel.doAction(.tapFavorite)
        } label: {
            viewModel.comic.favorited ? Image(systemName: "star.fill") : Image(systemName: "star")
        }
    }
}

// MARK: - Make Cell Row

private extension DetailView {
    func cellRow(episode: DisplayEpisode) -> some View {
        HStack {
            Text(episode.title)
            Spacer()
            Image(systemName: "checkmark")
                .bold()
                .foregroundStyle(.blue)
                .opacity(episode.selected ? 1 : 0)
        }
        .frame(minHeight: 44)
    }
}

// MARK: - Make Header

private extension DetailView {
    func header(comic: DisplayComic) -> some View {
        HStack(alignment: .top, spacing: 8) {
            headerCoverImage(comic: comic)
            
            VStack(alignment: .leading, spacing: 4) {
                headerTitle(comic: comic)
                headerAuthor(comic: comic)
                headerDescription(comic: comic)
            }
            
            Spacer()
        }
        .padding(16)
    }
    
    func headerCoverImage(comic: DisplayComic) -> some View {
        KFImage(URL(string: "https:" + comic.coverURI))
            .resizable()
            .frame(width: 70, height: 90)
    }
    
    func headerTitle(comic: DisplayComic) -> some View {
        Text(comic.title)
            .font(.headline)
            .lineLimit(2)
    }
    
    func headerAuthor(comic: DisplayComic) -> some View {
        Text(comic.author)
            .font(.subheadline)
    }
    
    func headerDescription(comic: DisplayComic) -> some View {
        Text(comic.description ?? "")
            .font(.subheadline)
            .lineLimit(lineLimit)
            .padding(.top, 8)
            .onTapGesture {
                lineLimit = lineLimit > 1 ? 1 : 4
            }
    }
}
/*
private extension Detail {
    struct Header: View {
        private let comic: DisplayComic
        @State var lineLimit = 4
        
        init(comic: DisplayComic) {
            self.comic = comic
        }
        
        var body: some View {
            HStack(alignment: .top, spacing: 8) {
                coverImage
                
                VStack(alignment: .leading, spacing: 4) {
                    title
                    author
                    description
                }
                
                Spacer()
            }
            .padding(16)
        }
        
        // MARK: - Computed Properties
        
        private var coverImage: some View {
            KFImage(URL(string: "https:" + comic.coverURI))
                .resizable()
                .frame(width: 70, height: 90)
        }
        
        private var title: some View {
            Text(comic.title)
                .font(.headline)
                .lineLimit(2)
        }
        
        private var author: some View {
            Text(comic.author)
                .font(.subheadline)
        }
        
        private var description: some View {
            Text(comic.description ?? "")
                .font(.subheadline)
                .lineLimit(lineLimit)
                .padding(.top, 8)
                .onTapGesture {
                    lineLimit = lineLimit > 1 ? 1 : 4
                }
        }
    }
}
*/
