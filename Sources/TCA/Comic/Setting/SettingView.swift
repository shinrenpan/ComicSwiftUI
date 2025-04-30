//
//  SettingView.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/12.
//

import ComposableArchitecture
import SwiftUI

@ViewAction(for: SettingFeature.self)
struct SettingView: View {
    @Bindable var store: StoreOf<SettingFeature>
    
    var body: some View {
        contentView
            .navigationTitle("設置")
            .navigationBarTitleDisplayMode(.inline)
            .alert($store.scope(state: \.alert, action: \.alertAction))
            .onAppear {
                send(.onAppear)
            }
    }
}

// MARK: - ViewBuilder

extension SettingView {
    @ViewBuilder
    var contentView: some View {
        Form {
            comicCount
            favoriteCount
            historyCount
            cacheSize
            version
        }
    }
    
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
            send(.favoriteTapped)
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
            send(.historyTapped)
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
            send(.cacheTapped)
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
