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
    @Binding var user: User
    
    @State var isLoading = false
    @State var tracks: [Track] = []
    @State var likedTracks: [Track] = []
    
    var isFollowed: Bool {
        (sc.usersImFollowing?.items ?? []).contains(user)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
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
            .padding(.top, -20)
            .padding(.horizontal)
            .fontDesign(.rounded)
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
        isLoading = true
        do {
            tracks = try await sc.getTracksForUser(user.id, 1000).items
            likedTracks = try await sc.getLikedTracksForUser(user.id, 1000).items
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
            HStack(spacing: 6) {
                HStack(spacing: 2) {
                    Image(systemName: "mappin").foregroundStyle(.blue)
                    Text(user.city ?? "?")
                }
                Spacer(minLength: 0)
                HStack(spacing: 2) {
                    Image(systemName: "person.wave.2.fill").foregroundStyle(Color.scOrange)
                    Text(user.followersCount.formattedIfOver1000)
                }
                Spacer(minLength: 0)
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
                print("Follow button tapped")
            } label: {
                Image(systemName: isFollowed ? "person.fill.checkmark" : "person.fill.badge.plus")
                    .foregroundStyle(Color.scOrange)
            }
        }
    }
    
    @ViewBuilder
    private var subscriptionLabel: some View {
        if user.subscription.lowercased() != "free" {
            Text(user.subscription)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 3)
                .background { LinearGradient.scOrange(.vertical) }
                .roundedCorner(4, corners: .allCorners)
                .offset(y: 3)
        }
    }
    
    private func playlistSection(_ title: String, _ tracks: [Track]) -> some View {
        VStack {
            HStack {
                Text(title)
                Spacer()
                Text(String(localized: "View all"))
                    .foregroundStyle(.secondary)
            }
            .font(.footnote)
            .onTapGesture {
                // Go to PlaylistView
            }
            ForEach(Array(tracks.prefix(3))) { track in
                TrackCellView(
                    track: .constant(track),
                    isPlaying: sc.loadedTrack == track,
                    isDownloaded: sc.downloadedTracks.contains(track)
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        UserDetailView(user: .constant(testUser(27127117)))
            .environmentObject(testSC)
    }
}
