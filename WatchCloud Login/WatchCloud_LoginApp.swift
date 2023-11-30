//
//  WatchCloud_LoginApp.swift
//  WatchCloud Login
//
//  Created by Ryan Forsyth on 2023-11-30.
//

import SwiftUI

@main
struct WatchCloud_LoginApp: App {
    
    init() {
        _ = WCPhoneSessionHandler.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
