//
//  PlaylistListView.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-05.
//

import SoundCloud
import SwiftUI

struct PlaylistListView: View {
    
    @EnvironmentObject var audioStore: AudioStore
    
    @Binding var playlists: [Playlist]
    @Binding var canLoadMore: Bool
    
    @State var selectedPlaylist: Playlist? = nil
    
    let title: String
    var reachedBottomOfList: (() -> Void)? = nil
    
    var body: some View {
        List {
            ForEach($playlists, id: \.id) { playlist in
                Button {
                    tapped(playlist.wrappedValue)
                } label: {
                    PlaylistCellView(playlist: playlist)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            Group {
                if canLoadMore, let reachedBottomOfList {
                    userListLoadingView.onAppear {
                        reachedBottomOfList()
                    }
                } else {
                    Text("End of list")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .fullWidth()
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
        }
        .animation(.default, value: playlists)
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
        #warning("Move loading logic inside PlaylistView! Standardize loading for all playlists")
        Task {
            var playlistWithTracks = playlist
            let page = try await audioStore.getTracksForPlaylist(playlist.id)
            playlistWithTracks.updateWith(page)
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
        .padding(.vertical)
    }
}

#Preview {
    NavigationStack {
        PlaylistListView(
            playlists: .constant([testPlaylist(),testPlaylist(),testPlaylist(),testPlaylist(),]),
            canLoadMore: .constant(false),
            title: "Following"
//            reachedBottomOfList: {}
        )
        .environmentObject(AudioStore(testSC))
    }
}
