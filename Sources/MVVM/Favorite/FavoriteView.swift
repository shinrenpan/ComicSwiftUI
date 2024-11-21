//
//  FavoriteView.swift
//
//  Created by Joe Pan on 2024/10/28.
//

import UIKit
import SwiftUI
import Kingfisher

struct FavoriteView: View {
    @State private var viewModel = ViewModel()
    private let dateFormatter: DateFormatter = .init()
    
    var body: some View {
        ZStack {
            if viewModel.dataSource.isEmpty {
                emptyView
            }
            else {
                list
            }
        }
        .navigationTitle("收藏列表")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: String.self) { comicId in
            DetailView(comicId: comicId)
        }
        .onAppear {
            viewModel.doAction(.loadData)
        }
    }
}

// MARK: - Computed Properties

private extension FavoriteView {
    var list: some View {
        List {
            ForEach(viewModel.dataSource, id: \.id) { comic in
                NavigationLink(value: comic.id) {
                    cellRow(comic: comic)
                }
            }
        }
        .animation(.default, value: UUID())
        .tint(.clear) // https://stackoverflow.com/a/74909831
        .listStyle(.plain)
    }
    
    var emptyView: some View {
        Text("空空如也")
            .font(.largeTitle)
            .foregroundStyle(.secondary)
    }
}

// MARK: - Make Cell Row

private extension FavoriteView {
    func cellRow(comic: DisplayComic) -> some View {
        HStack(alignment: .top, spacing: 8) {
            cellCoverImage(comic: comic)
            
            VStack(alignment: .leading, spacing: 4) {
                cellTitle(comic: comic)
                cellNote(comic: comic)
                cellWatchData(comic: comic)
                cellLastUpdate(comic: comic)
            }
        }
        .swipeActions(edge: .leading) {
            cellButton(comic: comic)
        }
        .swipeActions(edge: .trailing) {
            cellButton(comic: comic)
        }
    }
    
    func cellButton(comic: DisplayComic) -> some View {
        Button("取消收藏") {
            let request = RemoveFavoriteRequest(comic: comic)
            viewModel.doAction(.removeFavorite(request: request))
        }
        .tint(.orange)
    }
    
    func cellCoverImage(comic: DisplayComic) -> some View {
        KFImage(URL(string: "https:" + comic.coverURI))
            .resizable()
            .frame(width: 70, height: 90)
    }
    
    func cellTitle(comic: DisplayComic) -> some View {
        Text(comic.title)
            .font(.headline)
    }
    
    func cellNote(comic: DisplayComic) -> some View {
        Text(comic.note)
            .font(.subheadline)
    }
    
    func cellWatchData(comic: DisplayComic) -> some View {
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
    
    func cellLastUpdate(comic: DisplayComic) -> some View {
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
