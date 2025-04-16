//
//  AppDelegate.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit
import WebKit
import SwiftUI
import ComposableArchitecture

actor LoadingActor {
    @Shared(.inMemory("isLoading")) static private var _isLoading = false
    
    static var isLoading: Bool {
        get {
            Self._isLoading
        }
        set {
            Self.$_isLoading.withLock { $0 = newValue }
        }
    }
}

@main
struct ComicApp: App {
    var body: some Scene {
        WindowGroup {
            comicMainView
        }
    }
}

// MARK: - Computed Properties

extension ComicApp {
    @ViewBuilder
    var comicMainView: some View {
        MainView()
            .overlay {
                if LoadingActor.isLoading { loadingView }
            }
        
    }
    
    @ViewBuilder
    var loadingView: some View {
        ProgressView() {
            Text("Loading...")
                .font(.largeTitle)
                .foregroundStyle(.white)
        }
        .controlSize(.extraLarge)
        .tint(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.6))
    }
}
