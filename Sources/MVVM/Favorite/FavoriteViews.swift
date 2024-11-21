//
//  FavoriteViews.swift
//
//  Created by Joe Pan on 2024/10/28.
//

import UIKit
import SwiftUI
import Kingfisher

extension Favorite {
    struct MainView: View {
        private let vm = VM()
        private let router = Router()
        
        var body: some View {
            ZStack {
                List {
                    ForEach(vm.dataSource, id: \.id) { comic in
                        NavigationLink(value: comic.id) {
                            makeComicRow(comic: comic)
                        }
                    }
                }
                .animation(.default, value: UUID())
                .listStyle(.plain)
            
                if vm.dataSource.isEmpty {
                    emptyView
                }
            }
            .navigationTitle("收藏列表")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: String.self) { comicId in
                router.toDetail(comicId: comicId)
            }
            .onAppear {
                vm.doAction(.loadData)
            }
        }
        
        // MARK: - Computed Properties
        
        private var emptyView: some View {
            Text("空空如也")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
        }
        
        // MARK: - Make Something
        
        private func makeComicRow(comic: DisplayComic) -> some View {
            Cell(comic: comic)
                .swipeActions(edge: .leading) {
                    makeRemoveButton(comic: comic)
                }
                .swipeActions(edge: .trailing) {
                    makeRemoveButton(comic: comic)
                }
        }
        
        private func makeRemoveButton(comic: DisplayComic) -> some View {
            Button("取消收藏") {
                vm.doAction(.removeFavorite(request: .init(comic: comic)))
            }
            .tint(.orange)
        }
    }
}

private extension Favorite {
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
            Text(comic.title)
                .font(.headline)
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
            
            return HStack {
                Text(text)
                    .font(.footnote)
                Text(comic.hasNew ? "New" : "")
                    .font(.footnote)
                    .bold()
                    .foregroundStyle(.red)
            }
        }
    }
}
