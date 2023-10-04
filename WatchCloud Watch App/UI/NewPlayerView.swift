//
//  NewPlayerView.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-09-26.
//

import SoundCloud
import SwiftUI

@available(watchOS 10, *)
struct NewPlayerView: View {
    
    @EnvironmentObject var sc: SoundCloud
    @EnvironmentObject private var player: SCAudioPlayer
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    @State private var showOptions = false
    
    @State var volume: Float = 0
    @State var showVolumeCircle = false
    @State var volumeCircleVisibleTime = 0
    let volumeTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack { // Needed for toolbar
            playerView
        }
    }
    
    private var playerView: some View {
        VStack(spacing: 14) {
            artwork
            trackInfoLabels
        }
        .padding(.bottom, 14)
        .padding(.top, -6)
        .toolbar {
            optionsButton
            playbackButtons
        }
        .sheet(isPresented: $showOptions) {
            if let currentTrackBinding = Binding($sc.loadedTrack) {
                PlayerOptionsView(track: currentTrackBinding)
            }
        }
        .background { VolumeControlView(hidden: true) } // Hack to control volume with crown
        .onReceive(player.systemVolumePublisher) {
            handleVolumeUpdate($0)
        }
        .onReceive(volumeTimer) { _ in
            volumeCircleVisibleTime += 1
        }
        .onChange(of: volumeCircleVisibleTime) { visibleTime in
            if visibleTime > 1 {
                showVolumeCircle = false
                volumeCircleVisibleTime = 0
            }
        }
        .opacity(isLuminanceReduced ? 0.5 : 1)
    }
    
    
    @ViewBuilder
    private var artwork: some View {
        GeometryReader { geo in
            CachedImageView(url: sc.loadedTrack?.largerArtworkUrl)
                .frame(width: geo.size.width / 2, height: geo.size.width / 2)
                .fixedSize()
                .fullWidthAndHeight()
                .opacity(player.isLoading ? 0.6 : 1)
                .animation(.default, value: player.isLoading)
        }
        .overlay {
            ZStack {
                if showVolumeCircle {
                    VolumeCircleView(progress: $volume, lineWidth: 5)
                        .background(.black) // VolumeCircleView has transparent bg
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        
                } else if player.isLoading {
                    ProgressView()
                }
            }
            .animation(.default, value: showVolumeCircle)
        }
    }
    
    private var trackInfoLabels: some View {
        VStack(alignment: .leading, spacing: -2) {
            if let currentTrack = sc.loadedTrack {
                MarqueeText(
                    text: currentTrack.title,
                    startDelay: 2.5
                )
                .fontWeight(.semibold)
                
                Text(verbatim: currentTrack.user.username)
                    .foregroundColor(.secondary)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .padding(.trailing, 4)
                    .animation(.default, value: sc.loadedTrack)
            }
        }
        .lineLimit(1)
    }
    
    private var trackExtraInfo: some View {
        HStack(spacing: 2) {
            if sc.loadedTrack?.userFavorite ?? false {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
            }
            if sc.isLoadedTrackDownloaded {
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .frame(height: 18)
        .padding(1)
    }
    
    private var yOffset: CGFloat = 2
    private var playbackButtons: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button {
                player.skipToPreviousTrack()
            } label: {
                Image(systemName:"backward.fill")
            }
            
            Button {
                player.togglePlayback()
            } label: {
                Image(systemName:player.isPlaying ? "pause.fill" : "play.fill")
                    .symbolReplaceEffect(2.0)
            }
            .controlSize(.large)
            .overlay {
                Circle()
                    .trim(from: 0, to: CGFloat(player.progress / Double(sc.loadedTrack?.durationInSeconds ?? 1)))
                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(LinearGradient.scOrange(.vertical, reversed: true))
                    .rotationEffect(.degrees(-90))
                    .opacity(player.isLoading ? 0.7 : 1)
                    .animation(.default, value: player.progress)
                    .animation(.default, value: player.isLoading)
                
            }
            .contentShape(.focusEffect, Circle())
            .accessibilityQuickAction(style: .outline) {
                Button(String(player.isPlaying ? "Pause" : "Play")) {
                    player.togglePlayback()
                }
            }
            .disabled(player.isLoading)
            
            Button {
                player.skipToNextTrack()
            } label: {
                Image(systemName:"forward.fill")
            }
        }
    }
    
    private var optionsButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showOptions = true
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(LinearGradient.scOrange(.horizontal))
            }
        }
    }
    
    private func handleVolumeUpdate(_ newVolume: Float) {
        showVolumeCircle = true
        volumeCircleVisibleTime = 0
        volume = newVolume
    }
}

@available(watchOS 10, *)
#Preview {
    NewPlayerView()
        .environmentObject({ () -> SoundCloud in
            testSC.loadedPlaylists = testDefaultLoadedPlaylists
            var track = testTrack()
            track.userFavorite = true
            testSC.loadedTrack = track
            testSC.downloadedTracks = [track]
            return testSC
        }())
        .environmentObject({ () -> SCAudioPlayer in
            let player = SCAudioPlayer(testSC)
            player.progress = 2500
            player.isPlaying = true
            return player
        }() )
}
