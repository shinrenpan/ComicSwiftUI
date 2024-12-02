//
//  SettingView+Model.swift
//
//  Created by Shinren Pan on 2024/5/25.
//

import UIKit

extension SettingView {
    
    // MARK: - Action / Request
    
    enum Action {
        case loadData
        case cleanFavorite
        case cleanHistory
        case cleanCache
    }
    
    // MARK: - Models
    
    enum SettingType {
        case localData
        case favorite
        case history
        case cacheSize
        case version
    }

    struct DisplaySetting: Identifiable {
        let id: SettingType
        let title: String
        let subTitle: String
    }
}
