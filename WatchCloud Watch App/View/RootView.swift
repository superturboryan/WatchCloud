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
    @State private var selectedTab: RootTab = .library
    
    var body: some View {
        ZStack {
            if loaded { rootTabView }
            else { loadingView }
        }
        .transition(.opacity)
        .animation(.default, value: loaded)
        .fullScreenCover(isPresented: Binding(get: { !sc.isLoggedIn }, set: { (_, _) in })) {
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
            if playlistIsLoaded { PlayerView().tag(RootTab.player) }
        }
        .tabViewStyle(PageTabViewStyle())
    }
    
    var loadingView: some View {
        ProgressView() {
            Text("Getting ready... \n\n💃🕺")
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .controlSize(.large)
        .tint(Color.scOrange)
        // On first load
        .task { await load() }
    }
    
    func load() async {
        do {
            try await sc.loadLibrary()
            loaded = true
        } catch {
            // TODO: Check error type before logging out (offline use?)
            print("❌ Loading library failed with error: \(error)")
            sc.logout()
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(testSC)
    }
}
