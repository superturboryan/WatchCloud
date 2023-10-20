//
//  DownloadsView.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-08-31.
//

import SoundCloud
import SwiftUI

struct DownloadsView: View {
    
    @EnvironmentObject var audioStore: AudioStore
    @EnvironmentObject var player: AudioPlayer
    
    @State var isEmpty = false
    
    var body: some View {
        ScrollView {
            VStack {
                // Four possible states:
                // 1 - Downloads in progress
                // 2 - Downloaded tracks exist
                // 3 - Neither 1 or 2 (Empty)
                // 4 - Both 1 and 2
                
                if !audioStore.downloadsInProgress.isEmpty {
                    downloadsInProgressList
                }
                
                if !audioStore.downloadedTracks.isEmpty {
                    downloadedTrackList
                } else if audioStore.downloadsInProgress.isEmpty {
                    downloadedTracksEmptyView
                }
            }
        }
        .disabled(audioStore.downloadsInProgress.isEmpty && audioStore.downloadedTracks.isEmpty)
        .fontDesign(.rounded)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(String(localized: "Downloads", comment: "Plural noun"))
    }
    
    #warning("🌍 Localize strings")
    var downloadsInProgressList: some View {
        Section(header: sectionHeaderView("In Progress (\(audioStore.downloadsInProgress.count))")) {
            ForEach(
                audioStore.downloadsInProgress
                    .filter { $0.value.totalUnitCount != 0 }
                    .sorted(by: { $0.value.fractionCompleted > $1.value.fractionCompleted }),
                id: \.key.id
            ) { track, progress in
                downloadInProgressCell(track, progress)
                .onLongPressGesture {
                    try? audioStore.cancelDownloadInProgress(for: track)
                }
            }
            .animation(.default, value: audioStore.downloadsInProgress)
        }
    }
    
    func downloadInProgressCell(_ track: Track, _ progress: Progress) -> some View {
        VStack(spacing: 4) {
            Text(verbatim: track.title)
                .lineLimit(1)

            HStack(spacing: 8) {
                ProgressView(value: progress.fractionCompleted, total: 1.0)
                    .progressViewStyle(LinearGradientProgressViewStyle(fill: .green, height: 8))
                    .animation(.default, value: progress.fractionCompleted)
                Text(verbatim: "\(Int(progress.fractionCompleted * 100.0))%")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .fixedSize()
            }
            .padding(.horizontal, 6)
        }
        .padding()
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(10)
    }
    
    #warning("🌍 Localize strings")
    var downloadedTrackList: some View {
        Section(
            header: sectionHeaderView("Downloaded (\(audioStore.downloadedTracks.count))"),
            footer: sectionFooterView("Press and hold track\n to remove download")
        ) {
            ForEach($audioStore.downloadedTracks) { displayedTrack in
                TrackCellView(
                    track: displayedTrack,
                    isPlaying: audioStore.loadedTrack == displayedTrack.wrappedValue,
                    isDownloaded: true
                )
                .onTapGesture { tapped(displayedTrack.wrappedValue) }
                .onLongPressGesture {
                    #warning("Handle error")
                    do {
                        try audioStore.removeDownload(displayedTrack.wrappedValue)
                        Haptics.click()
                    } catch {
                        print("❌ Error deleting download: \(error)");
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
        // ⚠️ Copied from PlaylistView.tapped, move to LibraryView?
        // Set queue
        if audioStore.nowPlayingQueue != audioStore.downloadedTracks {
            audioStore.setNowPlayingQueue(with: audioStore.downloadedTracks)
        }
        // Play track
        if audioStore.loadedTrack != track {
            // Start selected track from beginning
            player.loadAndPlayTrack(track)
        } else if !player.isPlaying {
            player.continuePlayback()
        }
        
        NotificationCenter.default.post(name: .switchToPlayerTab, object: nil)
    }
}

#Preview {
    return NavigationStack {
        DownloadsView()
            .environmentObject(AudioStore(testSC))
            .environmentObject(AudioPlayer(AudioStore(testSC)))
    }
}
