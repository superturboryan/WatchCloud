//
//  NewPlayerView.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-09-26.
//

import NukeUI
import SoundCloud
import SwiftUI

@available(watchOS 10, *)
struct NewPlayerView: View {
    
    @EnvironmentObject var sc: SoundCloud
    @EnvironmentObject private var player: SCAudioPlayer
    
    @State private var showOptions = false
    
    var body: some View {
        VStack {
            artwork
            trackInfoLabels
        }
        .padding(.top, -8)
        .padding(.bottom, 2)
        .toolbar {
            optionsButton
            shazamButton
            playbackButtons
        }
    }
    
    private var artwork: some View {
        LazyImage(url: URL(string: sc.loadedTrack!.largerArtworkUrl!)!) { state in
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
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(alignment: .topTrailing) {
//            trackExtraInfo
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
                    .font(.subheadline)
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
    
    private var yOffset: CGFloat = 6
    private var playbackButtons: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button {
                
            } label: {
                Image(systemName:"backward.fill")
            }
            .offset(y: yOffset)
            
            Button {
                
            } label: {
                Image(systemName:player.isPlaying ? "pause.fill" : "play.fill")
            }
            .controlSize(.large)
            .overlay {
                Circle()
                    .trim(from: 0, to: CGFloat(player.progress / Double(sc.loadedTrack!.durationInSeconds)))
                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(LinearGradient.scOrange(.vertical, reversed: true))
                    .rotationEffect(.degrees(-90))
                    .opacity(player.isPlaying ? 1 : 0.8)
                    .animation(.default, value: player.progress)
                    .animation(.default, value: player.isPlaying)
            }
            .offset(y: yOffset)
            
            Button {
                
            } label: {
                Image(systemName:"forward.fill")
            }
            .offset(y: yOffset)
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
    
    #warning("Remove before submitting 1.0.2!")
    private var shazamButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                print("Show shazam")
            } label: {
                Image(systemName: "shazam.logo.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 34) // Should this be custom size??
                    .foregroundStyle(LinearGradient.scOrange(.horizontal))
            }
            .buttonStyle(.plain)
        }
    }
}

@available(watchOS 10, *)
#Preview {
    NavigationStack {
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
}
