//
//  Functions.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/30.
//

import Foundation

func removeWebKitFolder() {
    guard let bundleId = Bundle.main.bundleIdentifier else {
        return
    }
    
    let url = URL.cachesDirectory.appending(path: "\(bundleId)/WebKit/")
    try? FileManager.default.removeItem(at: url)
}
