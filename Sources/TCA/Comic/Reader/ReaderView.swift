//
//  ReaderView.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/13.
//

import ComposableArchitecture
import SwiftUI
import Kingfisher

@ViewAction(for: ReaderFeature.self)
struct ReaderView: View {
    @Bindable var store: StoreOf<ReaderFeature>
    
    var body: some View {
        contentView
            .statusBarHidden(!store.showBar)
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
            .sheet(item: $store.scope(state: \.sheet?.episodePicker, action: \.sheetAction.episodePicker)) { store in
                NavigationStack {
                    EpisodePickerView(store: store)
                }
            }
            .onAppear {
                send(.onAppear)
            }
    }
}

// MARK: - ViewBuilder

extension ReaderView {
    @ViewBuilder
    var contentView: some View {
        ReaderList(imageData: store.images, isHorizontal: store.isHorizontal)
            .ignoresSafeArea(.all)
            .contentShape(.rect)
            .onTapGesture {
                send(.readerTapped)
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
            send(.prevButtonTapped)
        }
        .disabled(!store.hasPrev)
    }
    
    @ViewBuilder
    var moreButton: some View {
        Menu("更多...") {
            Button {
                send(.pickerButtonTapped)
            } label: {
                HStack {
                    Text("選取集數")
                    Image(systemName: "list.number")
                }
            }
            
            Button {
                send(.favoriteButtonTapped)
            } label: {
                HStack {
                    Text(store.comic.favorited ? "取消收藏" : "加入收藏")
                    Image(systemName: store.comic.favorited ? "star.fill" : "star")
                }
            }
            
            Button {
                send(.directionButtonTapped)
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
            send(.nextButtonTapped)
        }
        .disabled(!store.hasNext)
    }
}
