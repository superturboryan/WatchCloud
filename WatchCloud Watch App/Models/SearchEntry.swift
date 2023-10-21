//
//  SearchEntry.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-21.
//

import Foundation

struct SearchEntry: Codable {
    let type: SearchType
    let query: String
    init(_ type: SearchType, _ query: String) {
        self.type = type
        self.query = query
    }
}
