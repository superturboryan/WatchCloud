//
//  SearchEntry.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-21.
//

import Foundation

// 💡 Custom macro to add init?
struct SearchEntry: Codable, Equatable {
    let type: SearchType
    let query: String
    init(_ type: SearchType, _ query: String) {
        self.type = type
        self.query = query
    }
}

extension SearchEntry: Identifiable {
    var id: String {
        type.rawValue + query
    }
}
