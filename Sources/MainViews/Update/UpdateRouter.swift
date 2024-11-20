//
//  UpdateRouter.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit
import SwiftUI

extension Update {
    @MainActor
    final class Router {
        
        // MARK: - Public
        
        func toDetail(comicId: String) -> some View {
            Detail.MainView(comicId: comicId)
        }
        
        func toRemoteSearch() {
            /*
            let to = Search.VC()
            to.hidesBottomBarWhenPushed = true
            vc?.navigationController?.show(to, sender: nil)*/
        }
    }
}
