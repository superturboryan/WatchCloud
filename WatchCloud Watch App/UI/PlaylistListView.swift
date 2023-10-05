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
                        selectedPlaylist = playlist.wrappedValue
                    } label: {
                        playlistCellView(playlist.wrappedValue)
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
            if let selectedPlaylist {
                PlaylistView(playlist: .constant(selectedPlaylist)).onDisappear {
                    self.selectedPlaylist = nil
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(title)
        .buttonStyle(.plain)
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
    
    func playlistCellView(_ playlist: Playlist) -> some View {
        HStack(spacing: 8) {
            CachedImageView(url: playlist.largerArtworkUrlWithTrackAndUserFallback.absoluteString)
                .frame(width: 30, height: 30)

            Text(verbatim: playlist.title)

            Spacer()
        }
        .lineLimit(1)
        .padding(10)
        .background(.secondary.opacity(0.2))
        .cornerRadius(10)
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
