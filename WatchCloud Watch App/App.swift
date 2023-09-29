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
    
    @StateObject var sc = CompositionRoot.sc
    @StateObject var player = CompositionRoot.scAudioPlayer

    var body: some Scene {
        WindowGroup {
            CompositionRoot.rootView
                .environmentObject(sc)
                .environmentObject(player)
        }
    }
}
