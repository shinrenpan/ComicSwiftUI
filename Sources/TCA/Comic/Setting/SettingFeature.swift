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
        var version: String = ""
        @Presents var alert: AlertState<AlertAction>?
    }
    
    enum Action: Equatable {
        case loadData
        case dataLoaded(comicCount: Int, favoriteCount: Int, historyCount: Int, cacheSize: String, version: String)
        case showAlert(AlertType)
        case removeFavorite
        case removeHistory
        case removeCache
        case alert(PresentationAction<AlertAction>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadData:
                return .run { send in
                    let comicCount = await Storage.shared.getAllCount()
                    let favoriteCount = await Storage.shared.getFavoriteCount()
                    let historyCount = await Storage.shared.getHistoryCount()
                    let cacheSize = await getCacheImagesSize()
                    let version = Bundle.main.version + "/" + Bundle.main.build
                    
                    await send(.dataLoaded(
                        comicCount: comicCount,
                        favoriteCount: favoriteCount,
                        historyCount: historyCount,
                        cacheSize: cacheSize,
                        version: version
                    ))
                }
                
            case let .dataLoaded(comicCount, favoriteCount, historyCount, cacheSize, version):
                state.comicCount = comicCount
                state.favoriteCount = favoriteCount
                state.historyCount = historyCount
                state.cacheSize = cacheSize
                state.version = version
                return .none
                
            case let .showAlert(alertType):
                state.alert = AlertState {
                    TextState(alertType.title)
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                    ButtonState(role: .destructive, action: .confirmTapped(alertType)) {
                        TextState("確定清除")
                    }
                } message: {
                    TextState(alertType.message)
                }
                return .none
               
            case .removeFavorite:
                state.alert = nil
                
                return .run { send in
                    await Storage.shared.removeAllFavorite()
                    await send(.loadData)
                }
                
            case .removeHistory:
                state.alert = nil
                
                return .run { send in
                    await Storage.shared.removeAllHistory()
                    await send(.loadData)
                }
                
            case .removeCache:
                state.alert = nil
                
                return .run { send in
                    await ImageCache.default.asyncCleanDiskCache()
                    await send(.loadData)
                }
                
            case .alert(.presented(.confirmTapped(let alertType))):
                switch alertType {
                case .removeFavorite:
                    return .send(.removeFavorite)
                case .removeHistory:
                    return .send(.removeHistory)
                case .removeCache:
                    return .send(.removeCache)
                }
                
            case .alert:
                return .none
            }
        }
        .ifLet(\.alert, action: \.alert)
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

// MARK: - Alert

extension SettingFeature {
    enum AlertType {
        case removeFavorite
        case removeHistory
        case removeCache
        
        var title: String {
            switch self {
            case .removeFavorite: return "清除收藏紀錄"
            case .removeHistory: return "清除觀看紀錄"
            case .removeCache: return "清除暫存圖片"
            }
        }
        
        var message: String {
            switch self {
            case .removeFavorite: return "確定要清除所有收藏紀錄嗎？"
            case .removeHistory: return "確定要清除所有觀看紀錄嗎？"
            case .removeCache: return "確定要清除所有暫存圖片嗎？"
            }
        }
    }
    
    enum AlertAction: Equatable {
        case confirmTapped(AlertType)
    }
}
