//
//  String+Extensions.swift
//
//  Created by Shinren Pan on 2024/6/2.
//

import UIKit

// MARK: - Comtuted Properties

extension String {
    var big5: String {
        GBig.traditionalize(self)
    }
    
    var gb: String {
        GBig.simplify(self)
    }
}

// MARK: - UserAgent

extension String {
    enum UserAgent {
        case iOS
        case safari
        case custom(String)
    }
}

// MARK: - UserAgent Properties

extension String.UserAgent {
    var value: String {
        switch self {
        case .iOS:
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Mobile/15E148 Safari/604.1"
        case .safari:
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_3) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.5 Safari/605.1.15"
        case let .custom(string):
            string
        }
    }
}

// MARK: - JavaScript

extension String {
    enum JavaScript {
        case update
        case detail
        case images
        case search
    }
}

// MARK: - JavaScript Properties

extension String.JavaScript {
    var value: String {
        switch self {
        case .update:
            getJavaScript(fileName: "ComicUpdate")
        case .detail:
            getJavaScript(fileName: "ComicDetail")
        case .images:
            getJavaScript(fileName: "ComicImages")
        case .search:
            getJavaScript(fileName: "ComicSearch")
        }
    }
}

// MARK: - JavaScript Functions

extension String.JavaScript {
    func getJavaScript(fileName: String) -> String {
        if let path = Bundle.main.url(forResource: fileName, withExtension: "js"),
           let data = try? Data(contentsOf: path),
           let result = String(data: data, encoding: .utf8)
        {
            return result
        }
        else {
            return ""
        }
    }
}
