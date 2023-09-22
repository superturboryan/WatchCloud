//
//  ContentView.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-08-14.
//

import SoundCloud
import SwiftUI
import WatchKit

struct PlayerView: View {
    
    @EnvironmentObject var sc: SoundCloud
    @EnvironmentObject var player: SCAudioPlayer
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    @State var showOptions = false
    
    @State var volume: Float = 0
    @State var showVolumeCircle = false
    @State var volumeCircleVisibleTime = 0
    let volumeTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 16) {
                    info
                    playbackButtons
                    progressBar
                }
                .padding(.top, -10)
                .padding(.bottom, 10)
                .padding(.horizontal, 5)
            }
            .buttonStyle(.plain)
            .toolbar { optionsButton }
            .fontDesign(.rounded)
            .fullWidthAndHeight()
            .edgesIgnoringSafeArea([.horizontal, .bottom])
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showOptions) {
                if let currentTrackBinding = Binding($sc.loadedTrack) {
                    PlayerOptionsView(track: currentTrackBinding)
                        .background(.black.opacity(0.5))
                }
            }
            .opacity(isLuminanceReduced ? 0.5 : 1)
        }
    }
    
    var info: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let currentTrack = sc.loadedTrack {
                MarqueeText(
                    text: currentTrack.title,
                    startDelay: 2.5
                )
                .fontWeight(.semibold)
                HStack {
                    Text(verbatim: currentTrack.user.username)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    Spacer(minLength: 4)
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
                }
                .padding(.trailing, 4)
                .animation(.default, value: sc.loadedTrack)
            }
        }
        .lineLimit(1)
    }
    
    var playbackButtons: some View {
        HStack(spacing: 28) {
            // Previous
            Button { player.skipToPreviousTrack() } label: {
                Image(systemName: "backward.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 15, height: 15)
            }
            
            // Play-pause + Volume
            ZStack {
                if showVolumeCircle {
                    VolumeCircleView(progress: $volume, lineWidth: 4)
                        .background(.black) // VolumeCircleView has transparent bg
                } else {
                    Button { player.togglePlayback() } label: {
                        if player.isLoading {
                            ProgressView().tint(.scOrange)
                        } else {
                            Image(systemName: player.isPlaying ? "pause.circle" : "play.circle.fill" )
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    .contentShape(.focusEffect, Circle())
                    .accessibilityQuickAction(style: .outline) {
                        Button(String(player.isPlaying ? "Pause" : "Play")) {
                            player.togglePlayback()
                        }
                    }
                    .disabled(player.isLoading)
                }
            }
            .animation(.default, value: showVolumeCircle)
            .frame(width: 55, height: 55)
            
            // Next
            Button {
                player.skipToNextTrack()
            } label: {
                Image(systemName: "forward.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 15, height: 15)
            }
        }
        .background { VolumeControlView().opacity(0) } // Hack to control volume with crown
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
    }
    
    @ViewBuilder
    var progressBar: some View {
        VStack(spacing: 4) {
            ProgressView(value: player.progress, total: TimeInterval(sc.loadedTrack?.durationInSeconds ?? 1))
                .progressViewStyle(LinearGradientProgressViewStyle(
                    fill: LinearGradient.scOrange(.horizontal),
                    height: 6,
                    animation: .linear(duration: 1)
                ))
            HStack {
                Text(verbatim: Int(player.progress).timeStringFromSeconds)
                Spacer()
                Text(verbatim: "-\((sc.loadedTrack!.durationInSeconds - Int(player.progress)).timeStringFromSeconds)") // Time remaining
            }
            .font(.footnote)
            .padding(.horizontal, 4)
            .animation(.default, value: player.progress)
            
        }
    }

    var optionsButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                showOptions = true
            } label: {
                Image(systemName: "ellipsis")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22) // Should this be custom size??
                    .foregroundStyle(LinearGradient.scOrange(.horizontal))
            }
            .offset(y: -6)
        }
    }
    
    func handleVolumeUpdate(_ newVolume: Float) {
        showVolumeCircle = true
        volumeCircleVisibleTime = 0
        volume = newVolume
    }
}

#Preview {
    PlayerView()
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
            player.progress = 3015
            player.isPlaying = true
            return player
        }() )
}
