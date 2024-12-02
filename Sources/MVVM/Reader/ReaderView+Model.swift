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
    
    struct DisplayImage: Identifiable {
        let id: String
        let uri: String
        
        init(uri: String) {
            self.id = uri
            self.uri = uri
        }
    }
}
