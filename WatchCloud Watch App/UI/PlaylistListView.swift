//
//  PlaylistListView.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-05.
//

import SoundCloud
import SwiftUI

struct PlaylistListView: View {
    
    @EnvironmentObject var sc: SoundCloud
    
    @Binding var playlists: [Playlist]
    @Binding var canLoadMore: Bool
    
    @State var selectedPlaylist: Playlist? = nil
    
    let title: String
    var reachedBottomOfList: (() -> Void)? = nil
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach($playlists, id: \.id) { playlist in
                    Button {
                        tapped(playlist.wrappedValue)
                    } label: {
                        PlaylistCellView(playlist: playlist)
                    }
                }
                if canLoadMore, let reachedBottomOfList {
                    userListLoadingView.onAppear {
                        reachedBottomOfList()
                    }
                } else {
                    sectionFooterView(String(localized: "End of list"))
                }
            }
            .animation(.default, value: playlists)
        }
        .navigationDestination(isPresented: .constant(selectedPlaylist != nil)) {
            if let selectedPlaylist = Binding($selectedPlaylist) {
                PlaylistView(playlist: selectedPlaylist).onDisappear {
                    self.selectedPlaylist = nil
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(title)
        .buttonStyle(.plain)
    }
    
    func tapped(_ playlist: Playlist) {
        Task {
            var playlistWithTracks = playlist
            let page = try await sc.getTracksForPlaylist(with: playlist.id)
            playlistWithTracks.tracks = page.items
            playlistWithTracks.nextPageUrl = page.nextPage
            selectedPlaylist = playlistWithTracks
        }
    }
    
    var userListLoadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
                .tint(.scOrange)
            Text("Loading playlists...")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    NavigationStack {
        PlaylistListView(
            playlists: .constant([testPlaylist(),testPlaylist(),testPlaylist(),]),
            canLoadMore: .constant(false),
            title: "Following"
        )
        .environmentObject(testSC)
    }
}
