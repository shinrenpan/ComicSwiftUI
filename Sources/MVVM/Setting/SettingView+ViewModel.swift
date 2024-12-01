//
//  SettingView+ViewModel.swift
//
//  Created by Shinren Pan on 2024/5/25.
//

import Observation
@preconcurrency import Kingfisher
import UIKit

extension SettingView {
    @MainActor
    @Observable
    final class ViewModel{
        private(set) var data: DisplayData = .init()
        
        // MARK: - Public
        
        func doAction(_ action: Action) {
            switch action {
            case .loadData:
                actionLoadData()
            case .cleanFavorite:
                actionCleanFavorite()
            case .cleanHistory:
                actionCleanHistory()
            case .cleanCache:
                actionCleanCache()
            }
        }
        
        // MARK: - Handle Action

        private func actionLoadData() {
            Task {
                let comicCount = await ComicWorker.shared.getAllCount()
                let favoriteCount = await ComicWorker.shared.getFavoriteCount()
                let historyCount = await ComicWorker.shared.getHistoryCount()
                let cacheSize = await getCacheImagesSize()
                let version = Bundle.main.version + "/" + Bundle.main.build

                data.settings = [
                    .init(id: .localData, title: "本地資料", subTitle: "\(comicCount) 筆"),
                    .init(id: .favorite, title: "收藏紀錄", subTitle: "\(favoriteCount) 筆"),
                    .init(id: .history, title: "觀看紀錄", subTitle: "\(historyCount) 筆"),
                    .init(id: .cacheSize, title: "暫存圖片", subTitle: cacheSize),
                    .init(id: .version, title: "版本", subTitle: version),
                ]
            }
        }

        private func actionCleanFavorite() {
            Task {
                await ComicWorker.shared.removeAllFavorite()
                actionLoadData()
            }
        }

        private func actionCleanHistory() {
            Task {
                await ComicWorker.shared.removeAllHistory()
                actionLoadData()
            }
        }

        private func actionCleanCache() {
            Task {
                await ImageCache.default.asyncCleanDiskCache()
                actionLoadData()
            }
        }
        
        // MARK: - Get Something

        private func getCacheImagesSize() async -> String {
            let size: UInt = await (try? ImageCache.default.diskStorageSize) ?? 0

            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useKB, .useMB, .useGB]
            formatter.countStyle = .file

            return formatter.string(fromByteCount: Int64(size))
        }
    }
}
