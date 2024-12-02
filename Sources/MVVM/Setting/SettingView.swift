//
//  SettingView.swift
//
//  Created by Shinren Pan on 2024/5/25.
//

import Observation
import SwiftUI

struct SettingView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        list
            .navigationTitle("設置")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.doAction(.loadData)
            }
    }
}

// MARK: - Computed Properties

private extension SettingView {
    var list: some View {
        List {
            ForEach(viewModel.settings, id: \.id) { setting in
                cellRow(setting: setting)
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Make Cell Row

private extension SettingView {
    func cellRow(setting: DisplaySetting) -> some View {
        HStack {
            Text(setting.title)
                .font(.title2)
            Spacer()
            Text(setting.subTitle)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: 44)
    }
}
