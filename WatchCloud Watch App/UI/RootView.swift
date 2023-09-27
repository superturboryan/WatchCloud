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
    
    @EnvironmentObject var sc: SoundCloud
    
    @State var loaded = false
    @State var loading = false
    @State private var selectedTab: RootTab = .library
    
    let isRightToLeft = Locale.current.language.characterDirection == .rightToLeft
    
    var body: some View {
        ZStack {
            if loaded {
                rootTabView
            } else {
                loadingView
            }
        }
        .animation(.default, value: loaded)
        .fullScreenCover(isPresented: Binding(get: { !sc.isLoggedIn }) { _ in }) {
            LoginView()
        }
        // On login
        .onChange(of: sc.isLoggedIn) { if $0 { Task { await load() } } }
    }
    
    @ViewBuilder
    var rootTabView: some View {
        let playlistIsLoaded = !(sc.nowPlayingQueue?.isEmpty ?? true)
        TabView(selection: $selectedTab) {
            LibraryView(rootSelectedTab: $selectedTab).tag(RootTab.library)
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
    }
    
    var loadingView: some View {
        ProgressView() {
            VStack(spacing: 12) {
                Text("Getting ready...")
                Text(verbatim: isRightToLeft ? "🎶🎶" : "💃🕺")
            }
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .foregroundColor(.secondary)
        }
        .controlSize(.large)
        .tint(Color.scOrange)
        .opacity(loading ? 1 : 0)
        .animation(.default, value: loading)
        // On first load
        .task { await load() }
    }
    
    func load() async {
        loading = true
        do {
            try await sc.loadLibrary()
            loaded = true
        } catch SoundCloud.Error.userNotAuthorized {
            print("❌ AuthTokens don't exist or API denied access. Performing logout, presenting login screen...")
            sc.logout()
        } catch {
            print("Failed to load library but AuthTokens exist, going into offline mode...")
            loaded = true
        }
        loading = false
    }
}

#Preview {
    RootView().environmentObject(testSC)    
}
