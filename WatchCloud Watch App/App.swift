//
//  WatchCloudApp.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-09-12.
//

import SoundCloud
import SwiftUI

@main
struct WatchCloud_Watch_AppApp: App {
    
    @StateObject var sc = SoundCloud(
        clientId: Config.clientId,
        clientSecret: Config.clientSecret,
        redirectURI: Config.redirectURI
    )
    @StateObject var player = SCAudioPlayer()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sc)
                .environmentObject({() -> SCAudioPlayer in
                    player.setSC(sc)
                    return player
                }())
        }
    }
}
