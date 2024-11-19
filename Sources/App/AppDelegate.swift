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
            TabView {
                Tab("更新列表", systemImage: "list.bullet") {
                    NavigationView {
                        UpdateVC()
                            .navigationTitle("更新列表")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
                Tab("收藏列表", systemImage: "star") {
                    NavigationView {
                        FavoriteVC()
                            .navigationTitle("收藏列表")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
                Tab("觀看紀錄", systemImage: "clock") {
                    NavigationView {
                        HistoryVC()
                            .navigationTitle("觀看紀錄")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
                Tab("設置", systemImage: "gear") {
                    NavigationView {
                        SettingVC()
                            .navigationTitle("設置")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
            }
            .environment(\.horizontalSizeClass, .compact)
        }
    }
    
    // MARK: - Setup Something

    private func setupAppearance() {
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

    // MARK: - Do Something
    
    private func doCleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}

private struct UpdateVC: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Update.VC {
        Update.VC()
    }
    
    func updateUIViewController(_ uiViewController: Update.VC, context: Context) {}
}

private struct FavoriteVC: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Favorite.VC {
        Favorite.VC()
    }
    
    func updateUIViewController(_ uiViewController: Favorite.VC, context: Context) {}
}

private struct HistoryVC: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> History.VC {
        History.VC()
    }
    
    func updateUIViewController(_ uiViewController: History.VC, context: Context) {}
}

private struct SettingVC: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Setting.VC {
        Setting.VC()
    }
    
    func updateUIViewController(_ uiViewController: Setting.VC, context: Context) {}
}
