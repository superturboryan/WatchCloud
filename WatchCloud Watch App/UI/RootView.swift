//
//  PlaylistList.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-08-19.
//

import SoundCloud
import SwiftUI

enum RootTab { case library, player }

struct RootView: View {
    
    @EnvironmentObject var player: AudioPlayer
    @EnvironmentObject var audioStore: AudioStore
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var searchStore: SearchStore
    
    @State var loaded = false
    @State var loading = false
    @State private var selectedTab: RootTab = .library
    
    var body: some View {
        ZStack {
            if loaded {
                rootTabView
            } else {
                loadingView
                // On first load
                .task { await load() }
            }
        }
        .animation(.default, value: loaded)
        .fullScreenCover(isPresented: Binding(get: { !authStore.isLoggedIn }) { _ in }) {
            LoginView()
        }
        .onChange(of: authStore.isLoggedIn) { isLoggedIn in
            if isLoggedIn {
                Task { await load() }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .performLogout)) { _ in
            performLogout()
        }
    }
    
    @ViewBuilder
    var rootTabView: some View {
        let playlistIsLoaded = !audioStore.nowPlayingQueue.isEmptyOrNil
        TabView(selection: $selectedTab) {
            LibraryView().tag(RootTab.library)
            // 👇 Loading PlayerView is the culprit for "Attribute graph cycle detected"... 
            if playlistIsLoaded {
                if #available(watchOS 10, *) {
                    NewPlayerView().tag(RootTab.player)
                        .transition(.move(edge: .trailing))
                        .animation(.default, value: playlistIsLoaded)
                } else {
                    PlayerView().tag(RootTab.player)
                        .transition(.move(edge: .trailing))
                        .animation(.default, value: playlistIsLoaded)
                }
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .onReceive(NotificationCenter.default.publisher(for: .switchToPlayerTab)) { _ in
            switchToPlayerTabAfterDelay()
        }
    }
    
    private func switchToPlayerTabAfterDelay() {
        Task {
            try await Task.sleep(for: .seconds(0.4))
            withAnimation { selectedTab = .player }
        }
    }
    
    var loadingView: some View {
        ProgressView() {
            VStack(spacing: 12) {
                Text("Getting ready...")
                Text(verbatim: Config.isRightToLeft ? "🎶🎶" : "💃🕺")
            }
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .foregroundColor(.secondary)
        }
        .controlSize(.large)
        .tint(Color.scOrange)
        .opacity(loading ? 1 : 0)
        .animation(.default, value: loading)
    }
    
    func load() async {
        loading = true
        do {
            try await userStore.load()
            try await audioStore.load()
            searchStore.load()
            loaded = true
        } catch SoundCloud.Error.userNotAuthorized {
            print("❌ AuthTokens don't exist or API denied access. Performing logout, presenting login screen...")
            performLogout()
            return
        } catch SoundCloud.Error.tooManyRequests {
            AnalyticsManager.shared.log(.tooManyRequests)
            loaded = true
        } catch {
            print("Failed to load library but AuthTokens exist, going into offline mode...")
            loaded = true
        }
        AnalyticsManager.shared.log(.loadLibrarySuccess)
        loading = false
    }
    
    private func performLogout() {
        player.stop()
        authStore.logout()
        userStore.reset()
        searchStore.reset()
        AnalyticsManager.shared.log(.logout)
    }
}

#Preview {
    RootView()
        .environmentObject(testAudioPlayer)
        .environmentObject(AudioStore(testSC))
        .environmentObject(AuthStore(testSC))
        .environmentObject(UserStore(testSC))
}

extension Notification.Name {
    static let switchToPlayerTab = Notification.Name("switchToPlayerTab")
    static let performLogout = Notification.Name("performLogout")
}
