//
//  DetailViews.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import Kingfisher
import UIKit
import SwiftUI

extension Detail {
    struct MainView: View {
        private let vm: VM
        
        init(comicId: String) {
            self.vm = .init(comicId: comicId)
        }
        
        var body: some View {
            ZStack {
                VStack {
                    Header(comic: vm.comic)
                    
                    List {
                        ForEach(vm.comic.episodes, id: \.id) { episode in
                            makeEpisodeRow(episode: episode)
                        }
                    }
                    .animation(.default, value: UUID())
                    .tint(.clear) // https://stackoverflow.com/a/74909831
                    .listStyle(.plain)
                }
                
                if vm.isLoading {
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
                vm.doAction(.loadData)
            }
        }
        
        // MARK: - Computed Properties
        
        private var loadingView: some View {
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
        
        private var favoriteButton: some View {
            Button {
                vm.doAction(.tapFavorite)
            } label: {
                vm.comic.favorited ? Image(systemName: "star.fill") : Image(systemName: "star")
            }
        }
        
        // MARK: - Make Something
        
        func makeEpisodeRow(episode: DisplayEpisode) -> some View {
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
}

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
