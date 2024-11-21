//
//  SearchRouter.swift
//
//  Created by Joe Pan on 2024/11/5.
//

import UIKit
import SwiftUI

extension Search {
    @MainActor
    final class Router {
        weak var vc: VC?
        
        // MARK: - Public
        
        func toDetail(comicId: String) {
            let view = DetailView(comicId: comicId)
            let to = UIHostingController(rootView: view)
            to.hidesBottomBarWhenPushed = true
            vc?.navigationController?.show(to, sender: nil)
        }
    }
}
