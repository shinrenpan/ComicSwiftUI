//
//  HistoryRouter.swift
//
//  Created by Shinren Pan on 2024/5/23.
//

import UIKit
import SwiftUI

extension History {
    @MainActor
    final class Router {
        
        // MARK: - Public
        
        func toDetail(comicId: String) -> some View {
            Detail.MainView(comicId: comicId)
        }
    }
}
