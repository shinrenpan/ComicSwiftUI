//
//  UpdateCell.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/29.
//

import SwiftUI
import Kingfisher

struct UpdateCell: View {
    let comic: Comic
    let dateFormatter: DateFormatter = .init()
    
    var body: some View {
        contentView
    }
}

// MARK: - ViewBuilder

extension UpdateCell {
    @ViewBuilder
    var contentView: some View {
        HStack(alignment: .top, spacing: 8) {
            cover
            
            VStack(alignment: .leading, spacing: 4) {
                title
                note
                watchDate
                lastUpdate
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    var cover: some View {
        KFImage(URL(string: "https:" + comic.cover))
            .resizable()
            .frame(width: 70, height: 90)
    }
    
    @ViewBuilder
    var title: some View {
        HStack(alignment: .top) {
            if comic.favorited {
                Image(systemName: "star.fill")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            Text(comic.title)
                .font(.headline)
        }
    }
    
    @ViewBuilder
    var note: some View {
        Text(comic.note)
            .font(.subheadline)
    }
    
    @ViewBuilder
    var watchDate: some View {
        Text(makeWatchText())
            .font(.footnote)
            .padding(.top, 8)
    }
    
    @ViewBuilder
    var lastUpdate: some View {
        Text(makeLastUpdateText())
            .font(.footnote)
            .padding(.bottom, 12)
    }
}

// MARK: - Functions

extension UpdateCell {
    func makeWatchText() -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        if let watchDate = comic.watchDate {
            return "觀看時間: " + dateFormatter.string(from: watchDate)
        }
        
        return "觀看時間: 未觀看"
    }
    
    func makeLastUpdateText() -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let lastUpdate = Date(timeIntervalSince1970: comic.lastUpdate)
        
        return "最後更新: " + dateFormatter.string(from: lastUpdate)
    }
}
