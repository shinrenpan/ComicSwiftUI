//
//  MainView.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/13.
//

import SwiftUI
import UIKit
import WebKit

struct MainView: View {
    
    init() {
        setupAppearance()
        doCleanCookies()
    }
    
    var body: some View {
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

// MARK: - Computed Proerties

extension MainView {
    @ViewBuilder
    var tab1: some View {
        NavigationStack {
            UpdateView(store: .init(initialState: UpdateFeature.State(), reducer: {
                UpdateFeature()
            }))
        }
    }
    
    @ViewBuilder
    var tab2: some View {
        NavigationStack {
            FavoriteView(store: .init(initialState: FavoriteFeature.State(), reducer: {
                FavoriteFeature()
            }))
        }
    }
    
    @ViewBuilder
    var tab3: some View {
        NavigationStack {
            HistoryView(store: .init(initialState: HistoryFeature.State(), reducer: {
                HistoryFeature()
            }))
        }
    }
    
    @ViewBuilder
    var tab4: some View {
        NavigationStack {
            SettingView(store: .init(initialState: SettingFeature.State(), reducer: {
                SettingFeature()
            }))
        }
    }
}

// MARK: - Functions

extension MainView {
    @MainActor
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
    
    @MainActor
    func doCleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
