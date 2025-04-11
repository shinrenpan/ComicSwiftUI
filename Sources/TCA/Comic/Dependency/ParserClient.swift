//
//  ParserClient.swift
//  Comic
//
//  Created by Joe Pan on 2025/4/12.
//

import ComposableArchitecture
import AnyCodable
import Foundation
import WebParser

@DependencyClient
struct ComicParser {
    var updateList: @Sendable () async throws -> AnyCodable
    var detail: @Sendable (_ comicId: String) async throws -> AnyCodable
    var search: @Sendable (_ keywords: String, _ page: Int) async throws -> AnyCodable
    var images: @Sendable (_ comicId: String, _ episodeId: String) async throws -> AnyCodable
}

// MARK: - Functions

extension ComicParser {
    static func removeWebKit() {
        guard let bundleId = Bundle.main.bundleIdentifier else {
            return
        }
        
        let url = URL.cachesDirectory.appending(path: "\(bundleId)/WebKit/")
        try? FileManager.default.removeItem(at: url)
    }
}

// MARK: - DependencyKey

extension ComicParser: DependencyKey {
    static let liveValue = ComicParser(updateList: {
        removeWebKit()
        let parser = await WebParser.Parser(parserConfiguration: .update())
        return try await parser.decodeResult(AnyCodable.self)
    }, detail: { comicId in
        removeWebKit()
        let parser = await WebParser.Parser(parserConfiguration: .detail(comicId: comicId))
        return try await parser.decodeResult(AnyCodable.self)
    }, search: { keywords, page in
        removeWebKit()
        let parser = await WebParser.Parser(parserConfiguration: .search(keywords: keywords, page: page))
        return try await parser.decodeResult(AnyCodable.self)
    }, images: { comicId, episodeId in
        removeWebKit()
        let parser = await WebParser.Parser(parserConfiguration: .images(comicId: comicId, episodeId: episodeId))
        return try await parser.decodeResult(AnyCodable.self)
    })
}

// MARK: - DependencyValues

extension DependencyValues {
    var comicParser: ComicParser {
        get { self[ComicParser.self] }
        set { self[ComicParser.self] = newValue }
    }
}
