//
//  PlaylistView.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-08-19.
//

import NukeUI
import SoundCloud
import SwiftUI

struct PlaylistView: View {
    
    @EnvironmentObject var sc: SoundCloud
    @EnvironmentObject var player: SCAudioPlayer
    
    @State private var isFirstLoad = true
    @State private var isLoading = false
    
    @Binding var playlist: Playlist
    var downloadedTracks: [Track]
    
    var onFirstLoad: (() async throws -> Void)? = nil
    var didSelectTrack: (Track) -> Void
    var showHeader = true
    var scrollToNowPlaying = false
    var updateNowPlayingPlaylist = true
    
    var body: some View {
        GeometryReader { geo in
            ScrollViewReader { sv in
                ScrollView {
                    if showHeader {
                        header(container: geo, tracklistSV: sv)
                    }
                    if isLoading {
                        trackListLoadingView
                    } else {
                        trackList
                    }
                }
                .task {
                    if isFirstLoad, let onFirstLoad {
                        // TODO: Loading state, handle error
                        isFirstLoad = false
                        isLoading = true
                        try? await onFirstLoad()
                        isLoading = false
                    }
                    
                    if scrollToNowPlaying,
                    let nowPlaying = sc.loadedTrack,
                    (playlist.tracks ?? []).contains(nowPlaying) {
                        withAnimation { sv.scrollTo(nowPlaying.id, anchor: .center) }
                    }
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
    @ViewBuilder
    func header(container geo: GeometryProxy, tracklistSV: ScrollViewProxy) -> some View {
        let subtitleText =
            "\(playlist.trackCount) track\(playlist.trackCount == 0 ? "" : "s"), "
            + playlist.durationInSeconds.hoursAndMinutesStringFromSeconds
        let isTracksEmpty = playlist.tracks?.isEmpty ?? true
        let scrollToFirstTrack = {
            let firstTrackId = playlist.tracks?.first?.id ?? -1
            withAnimation { tracklistSV.scrollTo(firstTrackId, anchor: .top) }
        }
        
        VStack(spacing: 10) {
            
            // Artwork and play all button
            HStack(spacing: 8) {
                let size = CGSize(width: geo.size.width / 2.5, height: geo.size.width / 2.5)
                // First track or playlist artist artwork
                LazyImage(url: playlist.artworkUrlWithTrackAndUserFallback) { state in
                    ZStack {
                        if let image = state.image {
                            image.resizable().scaledToFit()
                        } else if state.error != nil {
                            Image(systemName: "x.circle").resizable().scaledToFit()
                        } else {
                            ProgressView()
                        }
                    }
                }
                .size(size)
                .cornerRadius(4)
                
                // "Play all" button, starts playlist from first track
                Button {
                    tapped(playlist.tracks!.first!)
                    scrollToFirstTrack()
                } label: {
                    Image(systemName: "play.square.stack")
                    .resizable()
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(LinearGradient.scOrange(.horizontal), .white)
                    .scaledToFit()
                    .size(size)
                    .scaleEffect(0.9)
                }
                .disabled(isTracksEmpty)
            }
            
            // Playlist info labels
            VStack(spacing: 0) {
                Text(verbatim: playlist.title)
                    .font(.headline)
                Text(verbatim: subtitleText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.9)
            
            // Share and shuffle buttons
            HStack(spacing: 4) {
                let bottomButtomSize = CGSize(width: (geo.size.width - 10) / 2, height: 40)

                // Share playlist url button
                ShareLink(item: URL(string: playlist.permalinkUrl)!) {
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .size(bottomButtomSize)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
                
                // Shuffle button
                Button { tappedShuffle() } label: {
                    Image(systemName: "shuffle")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .size(bottomButtomSize)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.scOrange)
                        .cornerRadius(8)
                }
                .disabled(isTracksEmpty)
            }
        }
        .size(geo.size)
    }
    
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
                ForEach(tracksBinding) { track in
                    TrackCellView(
                        track: track,
                        isPlaying: sc.loadedTrack == track.wrappedValue,
                        isDownloaded: downloadedTracks.contains(track.wrappedValue)
                    )
                    // .id() automatically applied when using ForEach(Identifiable) 🤓
                    .onTapGesture { tapped(track.wrappedValue) }
                }
                .animation(.default, value: playlist.tracks)
                
                if playlist.hasNextPage {
                    trackListLoadingView.onAppear {
                        Task {
                            try await sc.loadNextPageOfTracksForPlaylist(playlist)
                        }
                    }
                } else {
                    sectionFooterView("End of playlist")
                }
            }
            .padding(.top, 10)
        } else {
            Text("Playlist is empty")
                .foregroundColor(.secondary)
                .padding(20)
        }
    }
    
    // MARK: - Tap actions
    func tapped(_ track: Track) {
        // Set queue
        if let tracks = playlist.tracks, sc.nowPlayingQueue != tracks, updateNowPlayingPlaylist {
            sc.setNowPlayingQueue(with: tracks)
        }
        
        if sc.loadedTrack != track {
            // Start new track from beginning
            player.loadAndPlayTrack(track)
        } else if !player.isPlaying {
            // Continue playing
            player.continuePlayback()
        }
        // Let parent container know selection was made
        didSelectTrack(track)
    }
    
    func tappedShuffle() {
        sc.loadedPlaylists[PlaylistType.nowPlaying.rawValue]?.tracks = playlist.tracks?.shuffled()
        if let firstTrack = sc.loadedPlaylists[PlaylistType.nowPlaying.rawValue]?.tracks?.first {
            player.loadAndPlayTrack(firstTrack)
            didSelectTrack(firstTrack)
        }
    }
}

#Preview {
    NavigationStack {
        PlaylistView(
            playlist: Binding(get: { testPlaylist(empty: false) }, set: { _ in }),
            downloadedTracks: [],
            didSelectTrack: { _ in },
            showHeader: true
        )
        .environmentObject(testSC)
        .environmentObject(SCAudioPlayer(testSC))
    }
}
