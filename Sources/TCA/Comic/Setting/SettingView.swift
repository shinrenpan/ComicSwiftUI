//
//  SettingView.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/12.
//

import ComposableArchitecture
import SwiftUI

struct SettingView: View {
    @Bindable var store: StoreOf<SettingFeature>
    
    var body: some View {
        Form {
            comicCount
            favoriteCount
            historyCount
            cacheSize
            version
        }
        .navigationTitle("設置")
        .navigationBarTitleDisplayMode(.inline)
        .alert($store.scope(state: \.alert, action: \.alert))
        .onAppear {
            store.send(.loadData)
        }
    }
}

// MARK: - Computed Properties

extension SettingView {
    @ViewBuilder
    var comicCount: some View {
        HStack {
            Text("本地資料")
                .font(.headline)
            Spacer()
            Text("\(store.comicCount) 筆")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: 44)
    }
    
    @ViewBuilder
    var favoriteCount: some View {
        HStack {
            Text("收藏紀錄")
                .font(.headline)
            Spacer()
            Text("\(store.favoriteCount) 筆")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: 44)
        .contentShape(.rect)
        .onTapGesture {
            store.send(.showAlert(.removeFavorite))
        }
    }
    
    @ViewBuilder
    var historyCount: some View {
        HStack {
            Text("觀看紀錄")
                .font(.headline)
            Spacer()
            Text("\(store.historyCount) 筆")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: 44)
        .contentShape(.rect)
        .onTapGesture {
            store.send(.showAlert(.removeHistory))
        }
    }
    
    @ViewBuilder
    var cacheSize: some View {
        HStack {
            Text("暫存圖片")
                .font(.headline)
            Spacer()
            Text(store.cacheSize)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: 44)
        .contentShape(.rect)
        .onTapGesture {
            store.send(.showAlert(.removeCache))
        }
    }
    
    @ViewBuilder
    var version: some View {
        HStack {
            Text("版本")
                .font(.headline)
            Spacer()
            Text(store.version)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: 44)
    }
}

#Preview {
    SettingView(store: .init(initialState: SettingFeature.State(), reducer: {
        SettingFeature()
            ._printChanges()
    }))
}
