//
//  ReaderView.swift
//
//  Created by Shinren Pan on 2024/5/24.
//

import Observation
import SwiftUI
import Kingfisher

struct ReaderView: View {
    @State private var viewModel: ViewModel
    
    init(comicId: String, episodeId: String) {
        self.viewModel = .init(comicId: comicId, episodeId: episodeId)
    }
    
    var body: some View {
        ZStack {
            switch viewModel.data.isHorizontal {
            case true:
                hScrollView
            case false:
                vScrollView
            }
            
            if viewModel.data.isLoading {
                loadingView
            }
        }
        //.ignoresSafeArea(.all, edges: [.top, .leading, .trailing])
        .navigationTitle(viewModel.data.title)
        .toolbarVisibility(viewModel.data.hiddenBars ? .hidden : .visible, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                toolBarPrveButton
                Spacer()
                toolbarMenu
                Spacer()
                toolBarNextButton
            }
        }
        .toolbarVisibility(viewModel.data.hiddenBars ? .hidden : .visible, for: .bottomBar)
        .animation(.default, value: viewModel.data.hiddenBars)
        .defersSystemGestures(on: .bottom)
        .onAppear {
            viewModel.doAction(.loadData(request: .init(epidoseId: nil)))
        }
    }
}

// MARK: - Computed Properties

private extension ReaderView {
    var hScrollView: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: [GridItem()], alignment: .center, spacing: 0) {
                ForEach(viewModel.data.images, id: \.id) { image in
                    KFImage.url(.init(string: image.uri))
                        .requestModifier(viewModel.data.imageModifier)
                        .scaleFactor(UIScreen.main.scale)
                        .cacheOriginalImage()
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.main.bounds.width)
                        .contentShape(.rect)
                        .onTapGesture {
                            viewModel.doAction(.reloadHiddenBars)
                        }
                }
            }
        }.scrollTargetBehavior(.paging)
    }
    
    var vScrollView: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: [GridItem()], alignment: .center, spacing: 0) {
                ForEach(viewModel.data.images, id: \.id) { image in
                    KFImage.url(.init(string: image.uri))
                        .requestModifier(viewModel.data.imageModifier)
                        .scaleFactor(UIScreen.main.scale)
                        .cacheOriginalImage()
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.main.bounds.width)
                        .contentShape(.rect)
                        .onTapGesture {
                            viewModel.doAction(.reloadHiddenBars)
                        }
                }
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
    
    var toolBarPrveButton: some View {
        Button("上一話") {
            viewModel.doAction(.loadPrev)
        }
        .disabled(!viewModel.data.hasPrev || viewModel.data.isLoading)
    }
    
    var toolbarMenu: some View {
        var listButton: some View {
            Button {
                
            } label: {
                HStack {
                    Text("選取集數")
                    Image(systemName: "list.number")
                }
            }
        }
        
        var favoriteButton: some View {
            Button {
                viewModel.doAction(.updateFavorite)
            } label: {
                HStack {
                    Text(viewModel.data.favorited ? "取消收藏" : "加入收藏")
                    Image(systemName: viewModel.data.favorited ? "star.fill" : "star")
                }
            }
        }
        
        var directionButton: some View {
            Button {
                viewModel.doAction(.updateReadDirection)
            } label: {
                HStack {
                    Text(viewModel.data.isHorizontal ? "直式閱讀" : "橫向閱讀")
                    Image(systemName: viewModel.data.isHorizontal ? "arrow.up.and.down.text.horizontal" : "arrow.left.and.right.text.vertical")
                }
            }
        }
        
        return Menu("更多...") {
            directionButton
            favoriteButton
            listButton
        }
        .disabled(viewModel.data.isLoading)
    }
    
    var toolBarNextButton: some View {
        Button("下一話") {
            viewModel.doAction(.loadNext)
        }
        .disabled(!viewModel.data.hasNext || viewModel.data.isLoading)
    }
}
