//
//  UpdateViews.swift
//
//  Created by Joe Pan on 2024/10/30.
//

import UIKit
import SwiftUI
import Kingfisher

extension Update {
    struct MainView: View {
        private let vm = VM()
        private let router = Router()
        
        var body: some View {
            ZStack {
                List {
                    ForEach(vm.dataSource, id: \.id) { comic in
                        makeComicRow(comic: comic)
                    }
                }
                .animation(.default, value: UUID())
                .tint(.clear) // https://stackoverflow.com/a/74909831
                .listStyle(.plain)
                .refreshable {
                    vm.doAction(.loadRemote)
                }
                
                if vm.isLoading {
                    loadingView
                }
            }
            .navigationTitle("更新列表")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: String.self) { comicId in
                router.toDetail(comicId: comicId)
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
        
        // MARK: - Make Something
        
        private func makeComicRow(comic: DisplayComic) -> some View {
            NavigationLink(value: comic.id) {
                Cell(comic: comic)
                    .swipeActions(edge: .leading) {
                        makeFavoriteButton(comic: comic)
                    }
                    .swipeActions(edge: .trailing) {
                        makeFavoriteButton(comic: comic)
                    }
            }
        }
        
        private func makeFavoriteButton(comic: DisplayComic) -> some View {
            Button(comic.favorited ? "取消收藏" : "加入收藏") {
                vm.doAction(.changeFavorite(request: .init(comic: comic)))
            }
            .tint(comic.favorited ? Color.orange : Color.blue)
        }
    }
}

private extension Update {
    struct Cell: View {
        private let comic: DisplayComic
        private let dateFormatter: DateFormatter = .init()
        
        init(comic: DisplayComic) {
            self.comic = comic
        }
        
        var body: some View {
            HStack(alignment: .top, spacing: 8) {
                coverImage
                
                VStack(alignment: .leading, spacing: 4) {
                    title
                    note
                    watchData
                    lastUpdate
                }
            }
        }
        
        // MARK: - Computed Properties
        
        private var coverImage: some View {
            KFImage(URL(string: "https:" + comic.coverURI))
                .resizable()
                .frame(width: 70, height: 90)
        }
        
        private var title: some View {
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
        
        private var note: some View {
            Text(comic.note)
                .font(.subheadline)
        }
        
        private var watchData: some View {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            var text: String
            
            if let watchDate = comic.watchDate {
                text = "觀看時間: " + dateFormatter.string(from: watchDate)
            }
            else {
                text = "觀看時間: 未觀看"
            }
            
            return Text(text)
                .font(.footnote)
                .padding(.top, 8)
        }
        
        private var lastUpdate: some View {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let lastUpdate = Date(timeIntervalSince1970: comic.lastUpdate)
            let text = "最後更新: " + dateFormatter.string(from: lastUpdate)
            
            return Text(text)
                .font(.footnote)
                .padding(.bottom, 12)
        }
    }
}
