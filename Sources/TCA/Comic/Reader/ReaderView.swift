//
//  ReaderView.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/13.
//

import ComposableArchitecture
import SwiftUI
import Kingfisher

struct ReaderView: View {
    @Bindable var store: StoreOf<ReaderFeature>
    
    var body: some View {
        contentView
            .ignoresSafeArea(.all)
            .defersSystemGestures(on: .bottom)
            .navigationTitle(store.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarVisibility(store.showBar ? .visible : .hidden, for: .navigationBar)
            .toolbarVisibility(store.showBar ? .visible : .hidden, for: .bottomBar)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    toolbar
                }
            }
            .sheet(item: $store.scope(state: \.sheet, action: \.sheet)) { store in
                switch store.case {
                case let .episodePicker(store):
                    EpisodePickerView(store: store)
                }
            }
            .onAppear {
                store.send(.firstLoad)
            }
    }
}

// MARK: - Computed Properties

extension ReaderView {
    @ViewBuilder
    var contentView: some View {
        switch store.isHorizontal {
        case true:
            horizontalReader
        case false:
            verticalReader
        }
    }
    
    @ViewBuilder
    var horizontalReader: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: [GridItem()], alignment: .center, spacing: 0) {
                ForEach(store.images, id: \.id) { image in
                    imageView(image)
                }
            }
        }.scrollTargetBehavior(.paging)
    }
    
    @ViewBuilder
    var verticalReader: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: [GridItem()], alignment: .center, spacing: 0) {
                ForEach(store.images, id: \.id) { image in
                    imageView(image)
                }
            }
        }
    }
    
    @ViewBuilder
    var toolbar: some View {
        HStack {
            prevButton
            Spacer()
            moreButton
            Spacer()
            nextButton
        }
    }
    
    @ViewBuilder
    var prevButton: some View {
        Button("上一話") {
            store.send(.prevButtonTapped)
        }
        .disabled(!store.hasPrev)
    }
    
    @ViewBuilder
    var moreButton: some View {
        Menu("更多...") {
            Button {
                store.send(.episodePickerTapped)
            } label: {
                HStack {
                    Text("選取集數")
                    Image(systemName: "list.number")
                }
            }
            
            Button {
                store.send(.favoriteButtonTapped)
            } label: {
                HStack {
                    Text(store.comic.favorited ? "取消收藏" : "加入收藏")
                    Image(systemName: store.comic.favorited ? "star.fill" : "star")
                }
            }
            
            Button {
                store.send(.directionButtonTapped)
            } label: {
                HStack {
                    Text(store.isHorizontal ? "直式閱讀" : "橫向閱讀")
                    Image(systemName: store.isHorizontal ? "arrow.up.and.down.text.horizontal" : "arrow.left.and.right.text.vertical")
                }
            }
        }
    }
    
    @ViewBuilder
    var nextButton: some View {
        Button("下一話") {
            store.send(.nextButtonTapped)
        }
        .disabled(!store.hasNext)
    }
}

// MARK: - Functions

extension ReaderView {
    @ViewBuilder
    func imageView(_ image: ReaderFeature.Image) -> some View {
        let imageModifier = AnyModifier { request in
            var result = request
            result.setValue(.UserAgent.safari.value, forHTTPHeaderField: "User-Agent")
            result.setValue("https://tw.manhuagui.com", forHTTPHeaderField: "Referer")
            return result
        }

        KFImage.url(.init(string: image.uri))
            .placeholder { ProgressView().controlSize(.large) }
            .requestModifier(imageModifier)
            .scaleFactor(UIScreen.main.scale)
            .cacheOriginalImage()
            .resizable()
            .scaledToFit()
            .frame(maxWidth: UIScreen.main.bounds.width)
            .contentShape(.rect)
            .onTapGesture {
                store.send(.imageTapped)
            }
    }
}
