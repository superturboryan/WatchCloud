//
//  CompositionRoot.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-09-14.
//

import Foundation
import SoundCloud

enum CompositionRoot {
    // Use static let for singletons
    // Use computed static var to get new instances instead of singleton
    // Use closures to inject dependencies 
    // Use private for dependencies that should be injected inside CompositionRoot, not accessed directly
    
    static let rootView = RootView()
    
    @MainActor
    static let sc = SoundCloud(
        clientId: clientId,
        clientSecret: clientSecret,
        redirectURI: redirectURI
    )
    
    @MainActor
    static let scAudioPlayer = SCAudioPlayer(sc)
    
    private static let clientId = Config.clientId
    private static let clientSecret = Config.clientSecret
    private static let redirectURI = Config.redirectURI
}
