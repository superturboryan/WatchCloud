//
//  ColorScheme.swift
//  WatchCloud Login
//
//  Created by Ryan Forsyth on 2023-12-03.
//

import SwiftUI

extension ColorScheme {
    var readableText: Color { self == .dark ? Color.white : Color.black }
    var lessReadableText: Color { self == .dark ? Color.white.opacity(0.8) : Color.black.opacity(0.8) }
}
