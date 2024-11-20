//
//  FavoriteRouter.swift
//
//  Created by Shinren Pan on 2024/5/22.
//

import UIKit
import SwiftUI

extension Favorite {
    @MainActor
    final class Router {
        
        // MARK: - Public
        
        func toDetail(comicId: String) -> some View {
            Detail.MainView(comicId: comicId)
        }
    }
}
