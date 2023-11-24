//
//  PlaylistList.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-08-19.
//

import OSLog
import SoundCloud
import SwiftUI

enum RootTab { case library, player }

struct RootView: View {
    
    @EnvironmentObject var audioStore: AudioStore
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var searchStore: SearchStore
    
    @State private var isLoaded = false
    @State private var isLoading = false
    @State private var selectedTab: RootTab = .library
    
    var body: some View {
        ZStack {
            if isLoaded {
                rootTabView
            } else {
                loadingView
            }
        }
        .animation(.default, value: isLoaded)
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
    
    private var rootTabView: some View {
        TabView(selection: $selectedTab) {
            LibraryView().tag(RootTab.library)
            osDependentPlayerView
        }
        .tabViewStyle(PageTabViewStyle())
        .onReceive(NotificationCenter.default.publisher(for: .switchToPlayerTab)) { _ in
            switchToPlayerTabAfterDelay()
        }
    }
    
    @ViewBuilder
    private var osDependentPlayerView: some View {
        let playlistIsLoaded = !audioStore.nowPlayingQueue.isEmptyOrNil
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
                Text(verbatim: Config.isRightToLeftLanguage ? "🎶🎶" : "💃🕺")
            }
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .foregroundColor(.secondary)
        }
        .controlSize(.large)
        .tint(Color.scOrange)
        .opacity(isLoading ? 1 : 0)
        .animation(.default, value: isLoading)
        .task { await load() } // On first load
    }
    
    func load() async {
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            try await userStore.load()
            try await audioStore.load()
            searchStore.load()
            isLoaded = true
            AnalyticsManager.shared.log(.loadLibrarySuccess)
        } catch UserStore.Error.loadingMyProfile,
                SoundCloud.Error.userNotAuthorized {
            Logger.rootView.info("❌ Profile doesn't exist or API denied access. Performing logout, presenting login screen...")
            performLogout()
            return
        } catch SoundCloud.Error.tooManyRequests { // Review if this error is actually thrown
            AnalyticsManager.shared.log(.tooManyRequests)
            isLoaded = true
        } catch {
            Logger.rootView.info("Failed to load library but profile exists, going into offline mode...")
            isLoaded = true
        }
    }
    
    private func performLogout() {
        audioStore.reset()
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
