//
//  SettingFeature.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/12.
//

import ComposableArchitecture
import Foundation
import Kingfisher

@Reducer
struct SettingFeature {
    @ObservableState
    struct State: Equatable {
        var comicCount = 0
        var favoriteCount = 0
        var historyCount = 0
        var cacheSize = "0 B"
        var version = ""
        
        @Presents var alert: AlertState<AlertAction>?
    }
    
    enum Action: Equatable, ViewAction {
        case view(UIAction)
        case dataAction(DataAction)
        
        case alertAction(PresentationAction<AlertAction>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(let action):
                return handleViewAction(action, state: &state)
                
            case .dataAction(let action):
                return handleDataAction(action, state: &state)
                
            case .alertAction(let action):
                return handleAlertAction(action)
            }
        }
        .ifLet(\.alert, action: \.alertAction)
    }
}

// MARK: - View Action

extension SettingFeature {
    @CasePathable
    enum UIAction: Equatable {
        case onAppear
        case favoriteTapped
        case historyTapped
        case cacheTapped
    }
    
    func handleViewAction(_ action: UIAction, state: inout State) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .run { send in
                let comicCount = await Storage.shared.getAllCount()
                let favoriteCount = await Storage.shared.getFavoriteCount()
                let historyCount = await Storage.shared.getHistoryCount()
                let cacheSize = await getCacheImagesSize()
                let version = Bundle.main.version + "/" + Bundle.main.build
                
                let displayData = DisplayData(
                    comicCount: comicCount,
                    favoriteCount: favoriteCount,
                    historyCount: historyCount,
                    cacheSize: cacheSize,
                    version: version
                )
                
                await send(.dataAction(.dataLoaded(displayData)))
            }
            
        case .favoriteTapped:
            state.alert = AlertState {
                TextState("清除收藏紀錄")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("取消")
                }
                ButtonState(role: .destructive, action: .cleanFavorite) {
                    TextState("確定清除")
                }
            } message: {
                TextState("確定要清除所有收藏紀錄嗎？")
            }
            
            return .none
            
        case .historyTapped:
            state.alert = AlertState {
                TextState("清除觀看紀錄")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("取消")
                }
                ButtonState(role: .destructive, action: .cleanHistory) {
                    TextState("確定清除")
                }
            } message: {
                TextState("確定要清除所有觀看紀錄嗎？")
            }
            
            return .none
            
        case .cacheTapped:
            state.alert = AlertState {
                TextState("清除暫存圖片")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("取消")
                }
                ButtonState(role: .destructive, action: .cleanCache) {
                    TextState("確定清除")
                }
            } message: {
                TextState("確定要清除所有暫存圖片嗎？")
            }
            
            return .none
        }
    }
}

// MARK: - Data Action

extension SettingFeature {
    struct DisplayData: Equatable {
        let comicCount: Int
        let favoriteCount: Int
        let historyCount: Int
        let cacheSize: String
        let version: String
    }
    
    @CasePathable
    enum DataAction: Equatable {
        case dataLoaded(DisplayData)
    }
    
    func handleDataAction(_ action: DataAction, state: inout State) -> Effect<Action> {
        switch action {
        case .dataLoaded(let data):
            state.comicCount = data.comicCount
            state.historyCount = data.historyCount
            state.favoriteCount = data.favoriteCount
            state.cacheSize = data.cacheSize
            state.version = data.version
            return .none
        }
    }
}

// MARK: - Alert Action

extension SettingFeature {
    @CasePathable
    enum AlertAction: Equatable {
        case cleanFavorite
        case cleanHistory
        case cleanCache
    }
    
    func handleAlertAction(_ action: PresentationAction<AlertAction>) -> Effect<Action> {
        switch action {
        case .presented(.cleanFavorite):
            return .run { send in
                await Storage.shared.removeAllFavorite()
                await send(.view(.onAppear))
            }
            
        case .presented(.cleanHistory):
            return .run { send in
                await Storage.shared.removeAllHistory()
                await send(.view(.onAppear))
            }
            
        case .presented(.cleanCache):
            return .run { send in
                await ImageCache.default.asyncCleanDiskCache()
                await send(.view(.onAppear))
            }
            
        default:
            return .none
        }
    }
}

// MARK: - Functions

extension SettingFeature {
    func getCacheImagesSize() async -> String {
        let size: UInt = await (try? ImageCache.default.diskStorageSize) ?? 0
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        
        return formatter.string(fromByteCount: Int64(size))
    }
}
