//
//  DownloadsView.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-08-31.
//

import OSLog
import SoundCloud
import SwiftUI

struct DownloadsView: View {
    
    @EnvironmentObject var audioStore: AudioStore
    @EnvironmentObject var player: AudioPlayer
    
    @State var isEmpty = false
    
    var body: some View {
        // 💡 Four possible states:
        // 1 - Downloads in progress
        // 2 - Downloaded tracks exist
        // 3 - Both 1 and 2
        // 4 - Neither 1 or 2 (Empty)
        List {
            if !audioStore.downloadsInProgress.isEmpty {
                downloadsInProgressList
            }
            
            if !audioStore.downloadedTracks.isEmpty {
                downloadedTrackList
            } else if audioStore.downloadsInProgress.isEmpty {
                downloadedTracksEmptyView
            }
        }
        .disabled(audioStore.downloadsInProgress.isEmpty && audioStore.downloadedTracks.isEmpty)
        .fontDesign(.rounded)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(String(localized: "Downloads", comment: "Plural noun"))
    }
    
    var downloadsInProgressList: some View {
        Section(
            header: Text("In Progress (\(audioStore.downloadsInProgress.count))")
        ) {
            ForEach(
                audioStore.downloadsInProgress.sorted(by: { $0.value > $1.value }), 
                id: \.key.id
            ){ track, progress in
                downloadInProgressCell(track, progress)
                .onLongPressGesture {
                    try? audioStore.cancelDownloadInProgress(for: track)
                }
            }
            .animation(.default, value: audioStore.downloadsInProgress)
        }
    }
    
    func downloadInProgressCell(_ track: Track, _ progress: Double) -> some View {
        VStack(spacing: 4) {
            Text(verbatim: track.title)
                .lineLimit(1)

            HStack(spacing: 8) {
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(LinearGradientProgressViewStyle(fill: .green, height: 8))
                    .animation(.default, value: progress)
                Text(verbatim: "\(Int(progress * 100.0))%")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .fixedSize()
            }
            .padding(.horizontal, 6)
        }
        .padding()
        .background(Color.cellBG)
        .cornerRadius(10)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
    
    var downloadedTrackList: some View {
        Section(
            header: Text ("Downloaded (\(audioStore.downloadedTracks.count))"),
            footer: Text("Press and hold track\n to remove download").fullWidth()
        ) {
            ForEach($audioStore.downloadedTracks) { displayedTrack in
                TrackCellView(
                    track: displayedTrack.wrappedValue,
                    isPlaying: audioStore.loadedTrack == displayedTrack.wrappedValue,
                    isDownloaded: true
                )
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .onTapGesture { tapped(displayedTrack.wrappedValue) }
                .onLongPressGesture {
                    do {
                        try audioStore.removeDownload(displayedTrack.wrappedValue)
                        Haptics.click()
                    } catch {
                        Logger.downloadsView.error("Failed to remove download")
                    }
                }
            }
            .animation(.default, value: audioStore.downloadedTracks)
        }
    }
    
    var downloadedTracksEmptyView: some View {
        VStack(spacing: 4) {
            HStack(spacing: 10) {
                Text("Tap")
                Image(systemName: "ellipsis")
                    .font(.title2)
                    .foregroundStyle(LinearGradient.scOrange(.horizontal))
            }
            Text("in the top-left corner of the player, then tap")
            playerOptionsDownloadButton
            Text(" to download tracks to watch")
        }
        .fontWeight(.medium)
        .multilineTextAlignment(.center)
        .fullWidth()
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
    
    var playerOptionsDownloadButton: some View {
        Image(systemName: "arrow.down.circle")
            .resizable()
            .scaledToFit()
            .padding(.vertical, 10)
            .frame(width: 76, height: 45)
            .background(Color.green.opacity(0.2))
            .foregroundColor(.green)
            .clipShape(Capsule(style: .continuous))
            .scaleEffect(0.8)
    }
    
    func tapped(_ track: Track) {
        // ⚠️ Copied from PlaylistView.tapped
        // Set queue
        if audioStore.nowPlayingQueue != audioStore.downloadedTracks {
            audioStore.setNowPlayingQueue(with: audioStore.downloadedTracks)
        }
        // Play track
        if audioStore.loadedTrack != track {
            // Start selected track from beginning
            player.loadAndPlayTrack(track)
        } else if !player.isPlaying {
            player.playCommand()
        }
        
        NotificationCenter.default.post(name: .switchToPlayerTab, object: nil)
    }
}

#Preview {
    return NavigationStack {
        DownloadsView()
            .environmentObject({ () -> AudioStore in
                let store = AudioStore(testSC)
                Task {
                    await store.loadDefaultPlaylists()
                    store.downloadedTracks = [testTrack(), testTrack(), testTrack(), ]
                    store.downloadsInProgress = [
                        testTrack() : 0.5,
                        testTrack() : 0.9
                    ]
                }
                return store
            }())
            .environmentObject(testAudioPlayer)
    }
}
