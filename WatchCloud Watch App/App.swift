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
    
    @State var isLaunched = false // Use to determine first launch
    @Environment(\.scenePhase) var scenePhase

    init() {
        _ = AnalyticsManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            CompositionRoot.rootView
                .environmentObject(sc)
                .environmentObject(player)
                .onChange(of: scenePhase) { log($0) }
        }
    }
    
    private func log(_ scenePhase: ScenePhase) {
        let event = isLaunched ? scenePhase.event : .appLaunch
        AnalyticsManager.shared.log(event)
        isLaunched = true
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
