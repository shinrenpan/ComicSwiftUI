//
//  UpdateView.swift
//
//  Created by Joe Pan on 2024/10/30.
//

import UIKit
import SwiftUI
import Kingfisher

struct UpdateView: View {
    @State private var viewModel = ViewModel()
    private let dateFormatter: DateFormatter = .init()
    
    var body: some View {
        ZStack {
            list
        }
        .navigationTitle("更新列表")
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

private extension UpdateView {
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
        .refreshable {
            viewModel.doAction(.loadRemote)
        }
        .overlay {
            if viewModel.isLoading {
                loadingView
            }
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
}

// MARK: - Make Cell

private extension UpdateView {
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
            cellFavoriteButton(comic: comic)
        }
        .swipeActions(edge: .trailing) {
            cellFavoriteButton(comic: comic)
        }
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
        
        return Text(text)
            .font(.footnote)
            .padding(.bottom, 12)
    }
}