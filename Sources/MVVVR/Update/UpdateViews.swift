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
        
        var body: some View {
            let _ = Self._printChanges()
            
            ZStack {
                List {
                    ForEach(vm.dataSource, id: \.id) { comic in
                        Cell(comic: comic)
                            .swipeActions(edge: .leading) {
                                makeFavoriteView(comic: comic)
                            }
                            .swipeActions(edge: .trailing) {
                                makeFavoriteView(comic: comic)
                            }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    vm.doAction(.loadRemote)
                }
                
                if vm.isLoading {
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
            }
            .navigationTitle("更新列表")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                vm.doAction(.loadData)
            }
        }
        
        // MARK: - Make Something
        
        private func makeFavoriteView(comic: DisplayComic) -> some View {
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
            HStack(alignment: .top) {
                KFImage(URL(string: "https:" + comic.coverURI))
                    .resizable()
                    .frame(width: 70, height: 90)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        if comic.favorited {
                            Image(systemName: "star.fill")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        
                        Text(comic.title)
                            .font(.headline)
                    }
                    
                    Text(comic.note)
                        .font(.subheadline)
                    Spacer(minLength: 8)
                    Text(makeWatchDate())
                            .font(.footnote)
                    Text(makeLastUpdate())
                        .font(.footnote)
                    Spacer(minLength: 12)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        // MARK: - Make Something
        
        private func makeWatchDate() -> String {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            if let watchDate = comic.watchDate {
                return "觀看時間: " + dateFormatter.string(from: watchDate)
            }
            else {
                return "觀看時間: 未觀看"
            }
        }
        
        private func makeLastUpdate() -> String {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let lastUpdate = Date(timeIntervalSince1970: comic.lastUpdate)
            return "最後更新: " + dateFormatter.string(from: lastUpdate)
        }
    }
}
