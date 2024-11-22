//
//  AppDelegate.swift
//
//  Created by Shinren Pan on 2024/5/21.
//

import UIKit
import WebKit
import SwiftUI

@main
struct ComicApp: App {
    
    init() {
        setupAppearance()
        doCleanCookies()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                TabView {
                    Tab("更新列表", systemImage: "list.bullet") {
                        tab1
                    }
                    Tab("收藏列表", systemImage: "star") {
                        tab2
                    }
                    Tab("觀看紀錄", systemImage: "clock") {
                        tab3
                    }
                    Tab("設置", systemImage: "gear") {
                        tab4
                    }
                }
                .environment(\.horizontalSizeClass, .compact)
            }
        }
    }
}

// MARK: - Computed Properties

private extension ComicApp {
    var tab1: some View {
        NavigationStack {
            UpdateView()
                .navigationDestination(for: NavigationPath.ToDetail.self) { data in
                    DetailView(comicId: data.comicId)
                }
                .navigationDestination(for: NavigationPath.ToReader.self) { data in
                    ReaderView(comicId: data.comicId, episodeId: data.episodeId)
                        .ignoresSafeArea(.all)
                }
        }
    }
    
    var tab2: some View {
        NavigationStack {
            FavoriteView()
                .navigationDestination(for: NavigationPath.ToDetail.self) { data in
                    DetailView(comicId: data.comicId)
                }
                .navigationDestination(for: NavigationPath.ToReader.self) { data in
                    ReaderView(comicId: data.comicId, episodeId: data.episodeId)
                        .ignoresSafeArea(.all)
                }
        }
    }
    
    var tab3: some View {
        NavigationStack {
            HistoryView()
                .navigationDestination(for: NavigationPath.ToDetail.self) { data in
                    DetailView(comicId: data.comicId)
                }
                .navigationDestination(for: NavigationPath.ToReader.self) { data in
                    ReaderView(comicId: data.comicId, episodeId: data.episodeId)
                        .ignoresSafeArea(.all)
                }
        }
    }
    
    var tab4: some View {
        NavigationStack {
            SettingView()
        }
    }
}

// MARK: - Setup Something

private extension ComicApp {
    func setupAppearance() {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance.copy()
        UINavigationBar.appearance().compactAppearance = navAppearance.copy()
        UINavigationBar.appearance().compactScrollEdgeAppearance = navAppearance.copy()
        
        let barAppearance = UITabBarAppearance()
        barAppearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = barAppearance
        UITabBar.appearance().scrollEdgeAppearance = barAppearance.copy()
    }
}

// MARK: - Do Something

private extension ComicApp {
    private func doCleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}

private struct ReaderView: UIViewControllerRepresentable {
    let comicId: String
    let episodeId: String
    
    func makeUIViewController(context: Context) -> ReaderVC {
        ReaderVC(comicId: comicId, episodeId: episodeId)
    }
    
    func updateUIViewController(_ uiViewController: ReaderVC, context: Context) {}
}
