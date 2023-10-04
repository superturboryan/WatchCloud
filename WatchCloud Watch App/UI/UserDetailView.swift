//
//  UserDetailView.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-03.
//

import SoundCloud
import SwiftUI

struct UserDetailView: View {
    
    @EnvironmentObject var sc: SoundCloud
    @EnvironmentObject var player: SCAudioPlayer
    
    var user: User
    
    @State var isLoading = false
    @State var tracks: [Track] = []
    @State var likedTracks: [Track] = []
    
    var isFollowed: Bool {
        (sc.usersImFollowing?.items.map(\.id) ?? []).contains(user.id)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                summary
                if isLoading {
                    loadingView
                }
                if !tracks.isEmpty {
                    playlistSection("Top tracks", tracks.sorted(by: { $0.playbackCount ?? 0 > $1.playbackCount ?? 0 }))
                    playlistSection("Most recent", tracks.sorted(by: { $0.createdAt > $1.createdAt }))
                }
                if !likedTracks.isEmpty {
                    playlistSection("Liked tracks", likedTracks)
                }
            }
            .animation(.default, value: tracks)
            .animation(.default, value: likedTracks)
            .padding(.top, -20)
            .fontDesign(.rounded)
            .buttonStyle(.plain)
        }
        .task {
            if tracks.isEmpty && likedTracks.isEmpty {
                await loadTracks()
            }
        }
        .toolbar {
            followButton
        }
    }
    
    @MainActor
    private func loadTracks() async {
        let numberOfTracksToLoad = 1000
        isLoading = true
        do {
            tracks = try await sc.getTracksForUser(user.id, numberOfTracksToLoad).items
            likedTracks = try await sc.getLikedTracksForUser(user.id, numberOfTracksToLoad).items
        } catch {
            print("❌ Failed to load tracks for user")
        }
        isLoading = false
    }
    
    private var loadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
                .tint(.scOrange)
            Text("Loading tracks...")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 10)
    }
    
    private var summary: some View {
        VStack(spacing: 10) {
            CachedImageView(url: user.largerAvatarUrl)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(alignment: .bottom) {
                    subscriptionLabel
                }

            artistInfoLabels
        }
    }
    
    private var artistInfoLabels: some View {
        VStack {
            Text(user.username)
                .font(.headline)
            HStack(spacing: 8) {
                if let city = user.city, !city.isEmpty {
                    HStack(spacing: 2) {
                        Image(systemName: "mappin").foregroundStyle(.blue)
                        Text(verbatim: city)
                    }
                }
                HStack(spacing: 2) {
                    Image(systemName: "person.wave.2.fill").foregroundStyle(Color.scOrange)
                    Text(user.followersCount.formattedIfOver1000)
                }
                HStack(spacing: 2) {
                    Image(systemName: "music.note").foregroundStyle(Color.scOrange)
                    Text(user.trackCount.formattedIfOver1000)
                }
            }
            .font(.footnote)
            .minimumScaleFactor(0.8)
        }
        .lineLimit(1)
    }
    
    private var followButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                Task {
                    if isFollowed {
                        try await sc.unfollowUser(user)
                    } else {
                        try await sc.followUser(user)
                    }
                }
            } label: {
                Image(systemName: isFollowed ? "checkmark" : "plus")
                    .foregroundStyle(Color.scOrange)
                    .fontWeight(.bold)
            }
        }
    }
    
    @ViewBuilder
    private var subscriptionLabel: some View {
        if user.subscription.lowercased() != "free" {
            Text(verbatim: user.subscription)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 3)
                .background { LinearGradient.scOrange(.vertical) }
                .roundedCorner(4, corners: .allCorners)
                .offset(y: 3)
        }
    }
    
    @ViewBuilder
    private func playlistSection(_ title: String, _ tracks: [Track]) -> some View {
        let playlist = Playlist(id: 0, user: user, title: title, tracks: tracks)
        VStack(spacing: 12) {
            NavigationLink {
                PlaylistView(
                    playlist: .constant(playlist),
                    downloadedTracks: sc.downloadedTracks,
                    showHeader: false
                )
            } label: {
                HStack {
                    Text(title)
                    Spacer()
                    Text(String(localized: "See all"))
                        .foregroundStyle(.secondary)
                }
                .font(.footnote)
                .padding(.horizontal)
            }
            VStack(spacing: 4) {
                ForEach(Array(tracks.prefix(3))) { track in
                    TrackCellView(
                        track: .constant(track),
                        isPlaying: sc.loadedTrack == track,
                        isDownloaded: sc.downloadedTracks.contains(track)
                    ).onTapGesture {
                        tapped(track, in: tracks)
                    }
                }
            }
        }
    }
    
    private func tapped(_ track: Track, in trackList: [Track]) {
        // Copied from PlaylistView
        // Set queue
        if sc.nowPlayingQueue != trackList {
            sc.setNowPlayingQueue(with: trackList)
        }
        if sc.loadedTrack != track {
            // Start new track from beginning
            player.loadAndPlayTrack(track)
        } else  {
            // Continue playing
            player.continuePlayback()
        }
        NotificationCenter.default.post(name: .switchToPlayerTab, object: nil)
    }
}

#Preview {
    NavigationStack {
        UserDetailView(user: testUser(27127117))
            .environmentObject(testSC)
            .environmentObject(SCAudioPlayer(testSC))
    }
}
