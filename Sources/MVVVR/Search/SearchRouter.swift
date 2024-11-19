//
//  SearchRouter.swift
//
//  Created by Joe Pan on 2024/11/5.
//

import UIKit

extension Search {
    @MainActor
    final class Router {
        weak var vc: VC?
        
        // MARK: - Public
        
        func toDetail(comicId: String) {
            let to = Detail.VC(comicId: comicId)
            to.hidesBottomBarWhenPushed = true
            vc?.navigationController?.show(to, sender: nil)
        }
    }
}
