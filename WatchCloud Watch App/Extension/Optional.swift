//
//  Optional.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-08.
//

import Foundation

extension Optional where Wrapped: Collection {
    var isEmptyOrNil: Bool {
        guard let self else {
            return true
        }
        return self.isEmpty
    }
}
