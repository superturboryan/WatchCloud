//
//  WatchCloudApp.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-09-12.
//

import Nuke
import SoundCloud
import SwiftUI
import TipKit

struct WatchCloud_Watch_AppApp: App {
    
    @StateObject var audioStore = CompositionRoot.audioStore
    @StateObject var authStore = CompositionRoot.authStore
    @StateObject var userStore = CompositionRoot.userStore
    @StateObject var searchStore = CompositionRoot.searchStore
    @StateObject var player = CompositionRoot.audioPlayer
    
    @State var isFirstLaunch = true
    @Environment(\.scenePhase) var scene
    
    init() {
        initializeSharedInstances()
        configureTips()
    }
    
    var body: some Scene {
        WindowGroup {
           RootView()
                .environmentObject(audioStore)
                .environmentObject(authStore)
                .environmentObject(userStore)
                .environmentObject(searchStore)
                .environmentObject(player)
                .onChange(of: scene) { onSceneChange($0) }
        }
    }
}

private extension WatchCloud_Watch_AppApp {
    func onSceneChange(_ scene: ScenePhase) {
        let analyticsEvent = isFirstLaunch ? .appLaunch : scene.event
        AnalyticsManager.shared.log(analyticsEvent)
        isFirstLaunch = false
        
        if scene == .background {
            audioStore.saveNowPlayingInfo(withProgress: player.progress)
        }
    }
    
    func initializeSharedInstances() {
        _ = AnalyticsManager.shared
        ImagePipeline.shared = .init(configuration: .withDataCache) // Enables aggressive disk caching
        _ = PathMonitor.shared
        
        // 💡 Initialize SoundCloud instance before WCWatchSessionHandler so that SC can listen for
        //    newAuthToken notification if one has been enqueued for watch after logging in on phone
        _ = CompositionRoot.sc
        _ = WCWatchSessionHandler.shared
    }
    
    func configureTips() {
        if #available(watchOS 10, *) {
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }
    }
}

extension ScenePhase {
    var event: AnalyticsEvent {
        switch self {
        case .background: .appBackground
        case .inactive: .appInactive
        case .active: .appActive
        @unknown default: .appActive
        }
    }
}
