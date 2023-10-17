//
//  PlaylistView.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-08-19.
//

import SoundCloud
import SwiftUI

struct PlaylistView: View {
    
    @EnvironmentObject var sc: SoundCloud
    @EnvironmentObject var player: AudioPlayer
    
    @State private var isFirstLoad = true
    @State private var isLoading = false
    
    @Binding var playlist: Playlist
    
    var onFirstLoad: (() async throws -> Void)? = nil
    var showSummary = true
    var scrollToNowPlaying = false
    var updateNowPlayingPlaylist = true
    var showShuffleButton = true
    
    var isLiked: Bool {
        sc.myLikedPlaylistIds.contains(playlist.id)
    }
    
    var isUserPlaylist: Bool {
        PlaylistType(rawValue: playlist.id) != nil || sc.myPlaylistIds.contains(playlist.id)
    }
    
    var body: some View {
        ScrollViewReader { sv in
            ScrollView {
                if showSummary {
                    PlaylistSummaryView(
                        playlist: $playlist,
                        isLiked: .constant(isLiked),
                        isLikeable: !isUserPlaylist,
                        tappedPlayAll: { tappedPlayAll(sv) },
                        tappedLike: { tappedLike() }
                    )
                }
                
                if isLoading {
                    trackListLoadingView
                } else if !playlist.tracks.isEmptyOrNil {
                    trackList
                        .padding(.top)
                }
            }
            .task {
                #warning("Errors not handled")
                if isFirstLoad, let onFirstLoad {
                    isFirstLoad = false
                    isLoading = true
                    try? await onFirstLoad()
                    isLoading = false
                }
                
                if scrollToNowPlaying,
                let nowPlaying = sc.loadedTrack,
                (playlist.tracks ?? []).contains(nowPlaying) {
                    withAnimation { sv.scrollTo(nowPlaying.id, anchor: .top) }
                }
            }
        }
        .navigationTitle(playlist.title)
        .navigationBarTitleDisplayMode(.inline)
        .buttonStyle(.plain)
        .fontDesign(.rounded)
        .edgesIgnoringSafeArea([.horizontal, .bottom])
    }
    
    // MARK: - UI
    var trackListLoadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
                .tint(.scOrange)
            Text("Loading tracks...")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 10)
    }
    
    @ViewBuilder
    var trackList: some View {
        if let tracksBinding = Binding($playlist.tracks),
           !tracksBinding.wrappedValue.isEmpty {
            LazyVStack(spacing: 5) {
                
                if showShuffleButton {
                    shuffleButton
                }
                
                ForEach(tracksBinding) { track in
                    TrackCellView(
                        track: track,
                        isPlaying: sc.loadedTrack == track.wrappedValue,
                        isDownloaded: sc.downloadedTracks.contains(track.wrappedValue)
                    )
                    // .id() automatically applied when using ForEach(Identifiable) 🤓
                    .onTapGesture { tapped(track.wrappedValue) }
                }
                
                if playlist.hasNextPage {
                    trackListLoadingView.onAppear {
                        loadNextPageOfTracks()
                    }
                } else {
                    sectionFooterView(String(localized: "End of playlist"))
                }
            }
            .animation(.default, value: playlist.tracks)
        } else {
            Text("Playlist is empty")
                .foregroundColor(.secondary)
                .padding(20)
        }
    }
    
    private var shuffleButton: some View {
        Button { tappedShuffle() } label: {
            Image(systemName: "shuffle")
                .resizable()
                .scaledToFit()
                .fontWeight(.semibold)
                .padding()
                .frame(width: 40, height: 40)
                .foregroundStyle(LinearGradient.scOrange(.horizontal))
                .fullWidth()
                .background(Color.gray.opacity(0.2))
        }
        .cornerRadius(8)
        .disabled(playlist.tracks.isEmptyOrNil)

    }
    
    private func loadNextPageOfTracks() {
        Task {
            let page: Page<Track> = try await sc.pageOfItems(for: playlist.nextPageUrl!)
            playlist.tracks! += page.items
            playlist.nextPageUrl = page.nextPage
        }
    }
    
    // MARK: - Tap actions
    func tappedPlayAll(_ sv: ScrollViewProxy) {
        tapped(playlist.tracks!.first!)
        let firstTrackId = playlist.tracks?.first?.id ?? -1
        withAnimation { sv.scrollTo(firstTrackId, anchor: .center) }
        AnalyticsManager.shared.log(.tappedPlayAll)
    }
    
    func tapped(_ track: Track) {
        // Set queue
        if let tracks = playlist.tracks, sc.nowPlayingQueue != tracks, updateNowPlayingPlaylist {
            sc.setNowPlayingQueue(with: tracks)
        }
        
        if sc.loadedTrack != track {
            // Start new track from beginning
            player.loadAndPlayTrack(track)
        } else  {
            // Continue playing
            player.continuePlayback()
        }
        
        AnalyticsManager.shared.log(.tappedTrack)
        NotificationCenter.default.post(name: .switchToPlayerTab, object: nil)
    }
    
    func tappedLike() {
        Task {
            try await isLiked ?
            sc.unlikePlaylist(playlist) :
            sc.likePlaylist(playlist)
            AnalyticsManager.shared.log(.tappedLikePlaylist)
        }
    }
    
    func tappedShuffle() {
        sc.loadedPlaylists[PlaylistType.nowPlaying.rawValue]?.tracks = playlist.tracks?.shuffled()
        if let firstTrack = sc.loadedPlaylists[PlaylistType.nowPlaying.rawValue]?.tracks?.first {
            player.loadAndPlayTrack(firstTrack)
            
            AnalyticsManager.shared.log(.tappedShuffle)
            NotificationCenter.default.post(name: .switchToPlayerTab, object: nil)
        }
    }
}

#Preview {
    NavigationStack {
        PlaylistView(
            playlist: .constant(testPlaylist()),
            showSummary: true
        )
        .environmentObject(testSC)
        .environmentObject(AudioPlayer(testSC))
    }
}
