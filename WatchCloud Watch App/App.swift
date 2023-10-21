//
//  WatchCloudApp.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-09-12.
//

import SoundCloud
import SwiftUI
import TipKit

@main
struct WatchCloud_Watch_AppApp: App {
    
    @StateObject var audioStore = CompositionRoot.audioStore
    @StateObject var authStore = CompositionRoot.authStore
    @StateObject var userStore = CompositionRoot.userStore
    @StateObject var player = CompositionRoot.audioPlayer
    
    @State var isLaunched = false // Used to determine first launch
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        _ = AnalyticsManager.shared // Calls init on shared instance
        configureTipKit()
    }
    
    var body: some Scene {
        WindowGroup {
            CompositionRoot.rootView
                .environmentObject(audioStore)
                .environmentObject(authStore)
                .environmentObject(userStore)
                .environmentObject(player)
                .onChange(of: scenePhase) { log($0) }
        }
    }
}

private extension WatchCloud_Watch_AppApp {
    func log(_ scenePhase: ScenePhase) {
        let event = isLaunched ? scenePhase.event : .appLaunch
        AnalyticsManager.shared.log(event)
        isLaunched = true
    }
    
    func configureTipKit() {
        if #available(watchOS 10, *) {
            try? Tips.resetDatastore() // ⚠️ Always showing tips
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
