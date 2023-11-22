//
//  CompositionRoot.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-09-14.
//

import SoundCloud

/// Simplified dependency injection container
///
/// Use computed var to get new instances instead of singleton
///
/// Use private for dependencies that should be injected inside CompositionRoot, not accessed directly
enum CompositionRoot {

    static let audioPlayer = AudioPlayer(audioStore, authStore)
    
    // Stores
    @MainActor static let audioStore = AudioStore(sc)
    @MainActor static let userStore = UserStore(sc)
    static let authStore = AuthStore(sc)
    static let searchStore = SearchStore(sc)
    
    // Services
    private static let sc = SoundCloud(config)
    
    // Config
    private static let config = SoundCloud.Config(
        apiURL: Config.apiUrl,
        clientId: Config.clientId,
        clientSecret: Config.clientSecret,
        redirectURI: Config.redirectURI
    )
}
