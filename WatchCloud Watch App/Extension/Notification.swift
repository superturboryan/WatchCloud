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
    static let performLogout = Notification.Name("performLogout")
    static let reloadRootTabView = Notification.Name("reloadRootTabView")
    static let switchToPlayerTab = Notification.Name("switchToPlayerTab")
    
    // SoundCloud
    static let didReceiveAuthTokensFromPhone = Notification.Name("didReceiveAuthTokensFromPhone")
}

extension NotificationCenter {
    func postUsingMainActor(_ aName: NSNotification.Name, _ anObject: Any? = nil) {
        Task { await MainActor.run{
            post(name: aName, object: anObject)
        }}
    }
}
