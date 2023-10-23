//
//  UserView.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-03.
//

import SoundCloud
import SwiftUI

struct UserView: View {
    
    @EnvironmentObject var audioStore: AudioStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var player: AudioPlayer
    
    var user: User
    
    @State var isLoading = false
    @State var tracks: [Track] = []
    @State var likedTracks: [Track] = []
    
    @State var showFullDescriptionView = false

    var isFollowed: Bool {
        (userStore.usersImFollowing?.items.map(\.id) ?? []).contains(user.id)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                summary
                if isLoading {
                    loadingView
                }
                if !tracks.isEmpty {
                    playlistSection(
                        String(localized: "Top tracks"),
                        tracks.sorted(by: { $0.playbackCount ?? 0 > $1.playbackCount ?? 0 })
                    )
                    playlistSection(
                        String(localized: "Most recent", comment: "Playlist section title"),
                        tracks.sorted(by: { $0.createdAt > $1.createdAt })
                    )
                }
                if !likedTracks.isEmpty {
                    playlistSection(
                        String(localized: "Liked tracks"),
                        likedTracks
                    )
                }
            }
            .animation(.default, value: tracks)
            .animation(.default, value: likedTracks)
            .padding(.top, -14)
            .fontDesign(.rounded)
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $showFullDescriptionView) {
            fullDescriptionView
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
            tracks = try await audioStore.getTracksForUser(user.id, numberOfTracksToLoad).items
            likedTracks = try await audioStore.getLikedTracksForUser(user.id, numberOfTracksToLoad).items
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
        .padding(.bottom, 10)
    }
    
    private var summary: some View {
        VStack(spacing: 10) {
            CachedImageView(url: user.largerAvatarUrl)
                .square(Device.screenSize.width * 0.5)
                .clipShape(Circle())
                .overlay(alignment: .bottom) {
                    subscriptionLabel
                }
            artistInfoLabels
        }
        .padding(.horizontal)
        .fullWidth()
        .onTapGesture {
            if let description = user.description, !description.isEmpty {
                showFullDescriptionView = true
            }
        }
    }
    
    private var artistInfoLabels: some View {
        VStack(spacing: 2) {
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
            .minimumScaleFactor(0.8)
        }
        .font(.footnote)
        .lineLimit(1)
    }
    
    private var fullDescriptionView: some View {
        ScrollView(showsIndicators: false) {
            Text(user.description ?? "")
                .padding()
                .fullWidthAndHeight()
        }
    }

    private var followButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                AnalyticsManager.shared.log(.tappedFollowUser)
                Task {
                    try await (isFollowed ? userStore.unfollowUser(user) : userStore.followUser(user))
                }
            } label: {
                Image(systemName: isFollowed ? "checkmark" : "plus")
                    .symbolReplaceEffect()
                    .foregroundStyle(Color.scOrange)
                    .fontWeight(.bold)
            }
        }
    }
    
    @ViewBuilder
    private var subscriptionLabel: some View {
        if user.subscription.lowercased() != "free" {
            Text(verbatim: user.subscription)
                .lineLimit(1)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 3)
                .background { LinearGradient.scOrange(.vertical) }
                .roundedCorner(4, corners: .allCorners)
                .offset(y: 3)
        }
    }
    
    @ViewBuilder
    private func playlistSection(_ title: String, _ tracks: [Track], _ trackLimit: Int = 3) -> some View {
        let playlist = Playlist(id: 0, user: user, title: title, tracks: tracks)
        let hasMoreTracksToShow = tracks.count > trackLimit
        VStack(spacing: 12) {
            // See all button
            NavigationLink {
                PlaylistView(
                    playlist: .constant(playlist),
                    showSummary: false
                )
            } label: {
                HStack {
                    Text(title)
                    Spacer()
                    if hasMoreTracksToShow {
                        Text(String(localized: "See all"))
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.footnote)
                .padding(.horizontal)
            }
            .disabled(!hasMoreTracksToShow)
            // First three tracks from playlist
            VStack(spacing: 4) {
                ForEach(Array(tracks.prefix(trackLimit))) { track in
                    TrackCellView(
                        track: .constant(track),
                        isPlaying: audioStore.loadedTrack == track,
                        isDownloaded: audioStore.downloadedTracks.contains(track)
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
        if audioStore.nowPlayingQueue != trackList {
            audioStore.setNowPlayingQueue(with: trackList)
        }
        if audioStore.loadedTrack != track {
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
        UserView(user: testUser(27127117))
            .environmentObject(AudioStore(testSC))
            .environmentObject(UserStore(testSC))
            .environmentObject(AudioPlayer(AudioStore(testSC)))
    }
}
