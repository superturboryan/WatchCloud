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

    static let audioPlayer = AudioPlayer(audioStore, authStore)
    
    // Stores
    static let audioStore = AudioStore(sc)
    @MainActor static let userStore = UserStore(sc)
    static let authStore = AuthStore(sc)
    static let searchStore = SearchStore(sc)
    
    // Services
    static let sc: SoundCloud = {
        let sc = SoundCloud(config)
        sc.listenForNewAuthTokensNotification()
        return sc
    }()
    
    // Config
    private static let config = SoundCloud.Config(
        clientId: Config.clientId,
        clientSecret: Config.clientSecret,
        redirectURI: Config.redirectURI
    )
}

extension SoundCloud {
    func listenForNewAuthTokensNotification() {
        NotificationCenter.default.publisher(for: .didReceiveAuthTokensFromPhone).sink { [weak self] notification in
            self?.handleNewAuthTokensNotification(notification)
            NotificationCenter.default.postUsingMainActor(.reloadRootTabView)
        }.store(in: &self.subscriptions)
    }
}
