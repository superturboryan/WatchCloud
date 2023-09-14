//
//  ContentView.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-08-14.
//

import SoundCloud
import SwiftUI

struct PlayerView: View {
    
    @EnvironmentObject var sc: SoundCloud
    @EnvironmentObject var player: SCAudioPlayer
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    @State var showOptions = false
        
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 18) {
                    info
                    playbackButtons
                    progressBar
                }
                .padding(.bottom, 15)
                .padding(.top, 30)
                .padding(.horizontal, 5)
            }
            .toolbar { optionsButton }
            .focusable(true)
            .digitalCrownRotation(
                $player.volume,
                from: 0,
                through: 0.4,
                by: 0.0001,
                sensitivity: .low
            )
            .fontDesign(.rounded)
            .fullWidthAndHeight()
            .ignoresSafeArea()
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showOptions) {
                if let currentTrackBinding = Binding($sc.loadedTrack) {
                    PlayerOptionsView(track: currentTrackBinding)
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
                    Text(currentTrack.user.username)
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
            }
        }
        .lineLimit(1)
    }
    
    var playbackButtons: some View {
        HStack(spacing: 28) {
            Button {
                player.skipToPreviousTrack()
            } label: {
                Image(systemName: "backward.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 15, height: 15)
            }
            
            Button {
                player.togglePlayback()
            } label: {
                if player.isLoading {
                    ProgressView().tint(.scOrange)
                } else {
                    Image(systemName: player.isPlaying ? "pause.circle" : "play.circle.fill" )
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .frame(width: 50, height: 50)
            .contentShape(.focusEffect, Circle())
            .accessibilityQuickAction(style: .outline) {
                Button(player.isPlaying ? "Pause" : "Play") {
                    player.togglePlayback()
                }
            }
            .disabled(player.isLoading)
            
            Button {
                player.skipToNextTrack()
            } label: {
                Image(systemName: "forward.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 15, height: 15)
            }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    var progressBar: some View {
        VStack(spacing: 5) {
            ProgressView(value: player.progress, total: TimeInterval(sc.loadedTrack?.durationInSeconds ?? 1))
                .progressViewStyle(LinearGradientProgressViewStyle(
                    fill: LinearGradient.scOrange(.horizontal),
                    height: 6,
                    animation: .linear(duration: 1)
                ))
            HStack {
                Text(Int(player.progress).timeStringFromSeconds)
                Spacer()
                Text(sc.loadedTrack?.durationInSeconds.timeStringFromSeconds ?? "")
            }
            .font(.footnote)
        }
    }
    
    @ViewBuilder
    var artwork: some View {
        ZStack {
            if let currentTrack = sc.loadedTrack {
                let url = currentTrack.largerArtworkUrl ?? currentTrack.user.avatarUrl
                AsyncImage(url: URL(string: url)) { image in
                    image.image?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(4)
                    .shadow(radius: 10)
                }
            }
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var sc = testSC
    static var previews: some View {
        PlayerView()
        .environmentObject({ () -> SoundCloud in
            sc.loadedPlaylists = testDefaultLoadedPlaylists
            var track = testTrack()
            track.userFavorite = true
            sc.loadedTrack = track
            sc.downloadedTracks = [track]
            return sc
        }())
        .environmentObject({ () -> SCAudioPlayer in
            let player = SCAudioPlayer(sc)
            player.progress = 3015
            player.isPlaying = true
            return player
        }() )
    }
}
