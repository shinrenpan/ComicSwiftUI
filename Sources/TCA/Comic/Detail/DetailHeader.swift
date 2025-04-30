//
//  DetailHeader.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/29.
//

import SwiftUI
import Kingfisher

struct DetailHeader: View {
    let comic: Comic
    @State var lineLimit = 4
    
    var body: some View {
        contentView
            .padding(16)
    }
}

// MARK: - ViewBuilder

extension DetailHeader {
    @ViewBuilder
    var contentView: some View {
        HStack(alignment: .top, spacing: 8) {
            cover
            
            VStack(alignment: .leading, spacing: 4) {
                title
                author
                description
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
        Text(comic.title)
            .font(.headline)
            .lineLimit(2)
    }
    
    @ViewBuilder
    var author: some View {
        Text(comic.detail?.author ?? "")
            .font(.subheadline)
    }
    
    @ViewBuilder
    var description: some View {
        Text(comic.detail?.desc ?? "")
            .font(.subheadline)
            .lineLimit(lineLimit)
            .padding(.top, 8)
            .onTapGesture {
                lineLimit = lineLimit > 1 ? 1 : 4
            }
    }
}
