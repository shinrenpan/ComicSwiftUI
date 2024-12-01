//
//  ReaderView+Model.swift
//
//  Created by Shinren Pan on 2024/5/24.
//

import UIKit
import WebParser
import Kingfisher

extension ReaderView {
    // MARK: - Action / Request
    
    enum Action {
        case loadData(request: LoadDataRequest)
        case updateFavorite
        case loadPrev
        case loadNext
        case reloadHiddenBars
        case updateReadDirection
    }
    
    struct LoadDataRequest {
        let epidoseId: String?
    }
    
    // MARK: - Models
    
    struct ImageData: Identifiable {
        let id: String
        let uri: String
        
        init(uri: String) {
            self.id = uri
            self.uri = uri
        }
    }
    
    struct DisplayData {
        let comicId: String
        var episodeId: String
        var prevEpesodeId: String?
        var nextEpesodeId: String?
        var isLoading = false
        var isHorizontal = true
        var hiddenBars = false
        var title: String = ""
        var images: [ImageData] = []
        var favorited: Bool = false
        var hasPrev: Bool { prevEpesodeId != nil }
        var hasNext: Bool { nextEpesodeId != nil }
        let imageModifier = AnyModifier { request in
            var result = request
            result.setValue(.UserAgent.safari.value, forHTTPHeaderField: "User-Agent")
            result.setValue("https://tw.manhuagui.com", forHTTPHeaderField: "Referer")
            return result
        }
        
        init(comicId: String = "", episodeId: String = "") {
            self.comicId = comicId
            self.episodeId = episodeId
        }
    }
}
