//
//  Color.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-11-19.
//

import SwiftUI

extension Color {
    
    static var cellBG: Color {
        .gray.opacity(0.2)
    }
    
    static var offBlack: Color {
        Color(uiColor: UIColor(white: 0.1, alpha: 1))
    }
}
