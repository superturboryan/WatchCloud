//
//  Notification.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-11-19.
//

import Foundation

extension Notification.Name {
    
    // AudioPlayer
    static let loadedNowPlayingInfo = Notification.Name("loadedNowPlayingInfo")
    
    // RootView
    static let switchToPlayerTab = Notification.Name("switchToPlayerTab")
    static let performLogout = Notification.Name("performLogout")
    
    // SoundCloud
    static let newAuthTokens = Notification.Name("newAuthTokens")
}
