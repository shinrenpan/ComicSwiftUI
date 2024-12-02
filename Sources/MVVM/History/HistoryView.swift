//
//  HistoryView.swift
//
//  Created by Joe Pan on 2024/10/28.
//

import UIKit
import SwiftUI
import Kingfisher

struct HistoryView: View {
    @State private var viewModel = ViewModel()
    private let dateFormatter: DateFormatter = .init()
    
    var body: some View {
        ZStack {
            list
        }
        .navigationTitle("觀看紀錄")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.doAction(.loadData)
        }
    }
}

// MARK: - Computed Properties

private extension HistoryView {
    var list: some View {
        List {
            ForEach(viewModel.data.comics, id: \.id) { comic in
                let to = NavigationPath.ToDetail(comicId: comic.id)
                ZStack {
                    NavigationLink(value: to) {}.opacity(0) // 移除 >
                    cellRow(comic: comic)
                }
            }
        }
        .animation(.default, value: UUID())
        .tint(.clear) // https://stackoverflow.com/a/74909831
        .listStyle(.plain)
        .overlay {
           if viewModel.data.comics.isEmpty {
                emptyView
            }
        }
    }
    
    var emptyView: some View {
        Text("空空如也")
            .font(.largeTitle)
            .foregroundStyle(.secondary)
    }
}

// MARK: - Make Cell Row

private extension HistoryView {
    func cellRow(comic: DisplayComic) -> some View {
        HStack(alignment: .top, spacing: 8) {
            cellCoverImage(comic: comic)
            
            VStack(alignment: .leading, spacing: 4) {
                cellTitle(comic: comic)
                cellNote(comic: comic)
                cellWatchData(comic: comic)
                cellLastUpdate(comic: comic)
            }
            
            Spacer()
        }
        .swipeActions(edge: .leading) {
            cellRemoveButton(comic: comic)
        }
        .swipeActions(edge: .leading) {
            cellFavoriteButton(comic: comic)
        }
        .swipeActions(edge: .trailing) {
            cellRemoveButton(comic: comic)
        }
        .swipeActions(edge: .trailing) {
            cellFavoriteButton(comic: comic)
        }
    }
    
    func cellRemoveButton(comic: DisplayComic) -> some View {
        Button("移除紀錄") {
            let request = RemoveHistoryRequest(comic: comic)
            viewModel.doAction(.removeHistory(request: request))
        }
        .tint(.red)
    }
    
    func cellFavoriteButton(comic: DisplayComic) -> some View {
        Button(comic.favorited ? "取消收藏" : "加入收藏") {
            let request = ChangeFavoriteRequest(comic: comic)
            viewModel.doAction(.changeFavorite(request: request))
        }
        .tint(comic.favorited ? Color.orange : Color.blue)
    }
    
    func cellCoverImage(comic: DisplayComic) -> some View {
        KFImage(URL(string: "https:" + comic.coverURI))
            .resizable()
            .frame(width: 70, height: 90)
    }
    
    func cellTitle(comic: DisplayComic) -> some View {
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
