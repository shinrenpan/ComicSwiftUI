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
                        NavigationStack {
                            UpdateView()
                        }
                    }
                    Tab("收藏列表", systemImage: "star") {
                        NavigationStack {
                            FavoriteView()
                        }
                    }
                    Tab("觀看紀錄", systemImage: "clock") {
                        NavigationStack {
                            History.MainView()
                        }
                    }
                    Tab("設置", systemImage: "gear") {
                        NavigationStack {
                            SettingVC()
                                .navigationTitle("設置")
                                .navigationBarTitleDisplayMode(.inline)
                        }
                    }
                }
                .environment(\.horizontalSizeClass, .compact)
            }
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

private struct SettingVC: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Setting.VC {
        Setting.VC()
    }
    
    func updateUIViewController(_ uiViewController: Setting.VC, context: Context) {}
}
