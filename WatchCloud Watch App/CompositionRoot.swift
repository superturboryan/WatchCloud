//
//  CompositionRoot.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-09-14.
//

import Foundation
import SoundCloud

/// Simplified dependency injection container
///
/// Use computed var to get new instances instead of singleton
///
/// Use private for dependencies that should be injected inside CompositionRoot, not accessed directly
enum CompositionRoot {
    
    // UI
    static let rootView = RootView()
    
    // Stores
    static let audioStore = AudioStore(soundCloudService)
    static let userStore = UserStore(soundCloudService)
    
    // Services
    private static let soundCloudService = SoundCloudService(config)
    
    // Config
    private static let config = SoundCloudConfig(
        apiURL: Config.apiUrl,
        clientId: Config.clientId,
        clientSecret: Config.clientSecret,
        redirectURI: Config.redirectURI
    )
    
    @MainActor
    static let scAudioPlayer = AudioPlayer(sc)
    
    @MainActor
    static let sc = SoundCloud(config)
}
