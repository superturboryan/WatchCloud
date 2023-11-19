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
    
    @EnvironmentObject var audioStore: AudioStore
    @EnvironmentObject private var player: AudioPlayer
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    @State private var showOptions = false
    
    @State var volume: Float = 0
    @State var showVolumeCircle = false
    @State var volumeCircleVisibleTime = 0
    let volumeTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    @State var isSeekButtonLongPressed = false
    
    var body: some View {
        NavigationStack { // Needed for toolbar
            VStack(spacing: 12) {
                if isLuminanceReduced, let track = audioStore.loadedTrack {
                    QRCodeImageView(url: track.permalinkUrl).scaleEffect(x: 1.2, y: 1.2)
                } else {
                    artwork.opacity(isLuminanceReduced ? 0 : 1)
                }
                trackInfoLabels
            }
            .animation(.default, value: isLuminanceReduced)
            .padding(.bottom, 6)
            .padding(.top, -6)
            .toolbar {
                optionsButton
                playbackButtons
            }
            .sheet(isPresented: $showOptions) {
                if let currentTrackBinding = Binding($audioStore.loadedTrack) {
                    PlayerOptionsView(track: currentTrackBinding)
                }
            }
            .background { volumeControlView } // Hack to control volume with crown
            .onReceive(AudioPlayer.systemVolumePublisher) {
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
    }
    
    @ViewBuilder
    private var artwork: some View {
        GeometryReader { geo in
            CachedImageView(url: audioStore.loadedTrack?.largerArtworkUrl)
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
            if let currentTrack = audioStore.loadedTrack {
                MarqueeText(
                    text: currentTrack.title,
                    startDelay: 2.5
                )
                .fontWeight(.semibold)
                
                Text(verbatim: currentTrack.user.username)
                    .foregroundColor(.secondary)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .padding(.trailing, 4)
                    .animation(.default, value: audioStore.loadedTrack)
            }
        }
        .padding(.bottom, 2)
        .lineLimit(1)
    }
    
    private var trackExtraInfo: some View {
        HStack(spacing: 2) {
            if audioStore.loadedTrack?.userFavorite ?? false {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
            }
            if audioStore.isLoadedTrackDownloaded {
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .frame(height: 18)
        .padding(1)
    }
    
    private var playbackButtons: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            skipAndSeekButton(.backward)
            togglePlaybackButton
            skipAndSeekButton(.forward)
        }
    }
    
    private var togglePlaybackButton: some View {
        Button { // ⏯️
            player.togglePlayback()
            AnalyticsManager.shared.log(.tappedTogglePlayback)
        } label: {
            Image(systemName:player.isPlaying ? "pause.fill" : "play.fill")
                .symbolReplaceEffect(2.0)
        }
        .controlSize(.large)
        .overlay { playbackCircleOverlay }
        .contentShape(.focusEffect, Circle())
        .accessibilityQuickAction(style: .outline) { // ♿️
            Button(String(player.isPlaying ? "Pause" : "Play")) {
                player.togglePlayback()
            }
        }
        .disabled(player.isLoading)
    }
    
    private func skipAndSeekButton(_ direction: AudioPlayer.SeekDirection) -> some View {
        Button { // ⏮️ ⏭️
            // 💡 After simultaneous `LongPressGesture` ends, this gesture is called a single time
            //    as well. Check if this closure is called as a result of the long press gesture
            //    (as opposed to a regular tap gesture) and the cancel the seeking
            if isSeekButtonLongPressed {
                player.endSeeking()
                isSeekButtonLongPressed.toggle()
            } else {
                direction.isBackward ? player.previousTrackCommand() : player.nextTrackCommand()
                AnalyticsManager.shared.log(direction.isBackward ? .tappedSkipToPreviousTrack : .tappedSkipToNextTrack)
            }
        } label: {
            Image(systemName: direction.isBackward ? "backward.fill" : "forward.fill")
        }
        .simultaneousGesture(LongPressGesture(minimumDuration: 0.3).onEnded { _ in
            isSeekButtonLongPressed = true
            player.beginSeeking(direction)
        })
    }
    
    private var playbackCircleOverlay: some View {
        Circle()
            .trim(from: 0, to: CGFloat(player.progress / Double(audioStore.loadedTrack?.durationInSeconds ?? 1)))
            .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .foregroundStyle(LinearGradient.scOrange(.vertical, reversed: true))
            .rotationEffect(.degrees(-90))
            .opacity(player.isLoading ? 0.7 : 1)
            // Only animate if not setting to 0
            .animation(.linear(duration: player.progress != 0 ? 1 : 0), value: player.progress)
            .animation(.default, value: player.isLoading)
    }
    
    private var optionsButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showOptions = true
                AnalyticsManager.shared.log(.tappedPlayerOptions)
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
    
    private var volumeControlView: some View {
        #if targetEnvironment(simulator)
        EmptyView()
        #else
        VolumeControlView(hidden: true)
        #endif
    }
}

@available(watchOS 10, *)
#Preview {
    NewPlayerView()
        .environmentObject({ () -> AudioStore in
            let audioStore = AudioStore(testSC)
            audioStore.loadedTrack = testTrack()
            return audioStore
        }())
        .environmentObject(UserStore(testSC))
        .environmentObject(testAudioPlayer)
        .environment(\.isLuminanceReduced, true)
}
