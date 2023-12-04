//
//  WatchCloud_LoginApp.swift
//  WatchCloud Login
//
//  Created by Ryan Forsyth on 2023-11-30.
//

import SoundCloud
import SwiftUI

@main
struct WatchCloud_LoginApp: App {
    
    static let sc = SoundCloud(SoundCloud.Config(
        clientId: Config.clientId,
        clientSecret: Config.clientSecret,
        redirectURI: Config.redirectURI
    ))
    
    @StateObject var authStore = AuthStore(sc, isLoggedIn: false)
    
    init() {
        _ = WCPhoneSessionHandler.shared
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authStore)
        }
    }
}
