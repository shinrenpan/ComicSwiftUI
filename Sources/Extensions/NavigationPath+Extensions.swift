//
//  NavigationPath+Extensions.swift
//
//  Created by Joe Pan on 2024/11/21.
//

import SwiftUI

extension NavigationPath {
    struct ToDetail: Hashable {
        let comicId: String
    }
    
    struct ToReader: Hashable {
        let comicId: String
        let episodeId: String
    }
    
    struct ToSearch: Hashable {}
}
