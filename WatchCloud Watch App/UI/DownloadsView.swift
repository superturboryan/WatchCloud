//
//  DownloadsView.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-08-31.
//

import SoundCloud
import SwiftUI

struct DownloadsView: View {
    
    @EnvironmentObject var sc: SoundCloud
    @EnvironmentObject var player: SCAudioPlayer
    
    @State var isEmpty = false
    
    var didSelectTrack: (Track) -> Void
    
    var body: some View {
        ScrollView {
            VStack {
                // Four possible states:
                // 1 - Downloads in progress
                // 2 - Downloaded tracks exist
                // 3 - Neither 1 or 2 (Empty)
                // 4 - Both 1 and 2
                
                if !sc.downloadsInProgress.isEmpty { downloadsInProgressList }
                
                if !sc.downloadedTracks.isEmpty { downloadedTrackList }
                else if sc.downloadsInProgress.isEmpty { downloadedTracksEmptyView }
            }
        }
        .disabled(sc.downloadsInProgress.isEmpty && sc.downloadedTracks.isEmpty)
        .fontDesign(.rounded)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Downloads")
    }
    
    var downloadsInProgressList: some View {
        Section(header: sectionHeaderView("In Progress (\(sc.downloadsInProgress.count))")) {
            ForEach(
                sc.downloadsInProgress
                    .filter { $0.value.totalUnitCount != 0 }
                    .sorted(by: { $0.value.fractionCompleted > $1.value.fractionCompleted }),
                id: \.key.id
            ) { track, progress in
                downloadInProgressCell(track, progress)
                .onLongPressGesture {
                    try? sc.cancelDownloadInProgress(for: track)
                }
            }
            .animation(.default, value: sc.downloadsInProgress)
        }
    }
    
    func downloadInProgressCell(_ track: Track, _ progress: Progress) -> some View {
        VStack(spacing: 4) {
            Text(track.title)
                .lineLimit(1)

            HStack(spacing: 8) {
                ProgressView(value: progress.fractionCompleted, total: 1.0)
                    .progressViewStyle(LinearGradientProgressViewStyle(fill: .green, height: 8))
                    .animation(.default, value: progress.fractionCompleted)
                Text("\(Int(progress.fractionCompleted * 100.0))%")
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
    
    var downloadedTrackList: some View {
        Section(
            header: sectionHeaderView("Downloaded (\(sc.downloadedTracks.count))"),
            footer: sectionFooterView("Press and hold track\n to remove download")
        ) {
            ForEach($sc.downloadedTracks) { displayedTrack in
                TrackCellView(
                    track: displayedTrack,
                    isPlaying: sc.loadedTrack == displayedTrack.wrappedValue,
                    isDownloaded: true
                )
                .onTapGesture { tapped(displayedTrack.wrappedValue) }
                .onLongPressGesture {
                    
                    do {
                        try sc.removeDownload(displayedTrack.wrappedValue)
                        Haptics.click()
                    } catch {
                        // TODO: Handle delete playing track error
                        print("❌ Error deleting download: \(error)");
                    }
                }
            }
            .animation(.default, value: sc.downloadedTracks)
        }
    }
    
    var downloadedTracksEmptyView: some View {
        VStack(spacing: 6) {
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
        .padding(.top)
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
        if sc.nowPlayingQueue != sc.downloadedTracks {
            sc.setNowPlayingQueue(with: sc.downloadedTracks)
        }
        // Play track
        if sc.loadedTrack != track {
            // Start selected track from beginning
            player.loadAndPlayTrack(track)
        } else if !player.isPlaying {
            player.continuePlayback()
        }
        // Let parent container know selection was made
        didSelectTrack(track)
    }
}

struct DownloadsView_Previews: PreviewProvider {
    static let sc: SoundCloud = { () -> SoundCloud in
        var sc = testSC
        sc.myUser = testUser
        sc.loadedPlaylists = testDefaultLoadedPlaylists
        sc.downloadsInProgress = [testTrack() : Progress.with(0.69)]
        sc.downloadedTracks = [testTrack(), testTrack(), testTrack()]
        return sc
    }()

    static var previews: some View {
        NavigationStack {
            DownloadsView(didSelectTrack: { _ in })
                .environmentObject(sc)
                .environmentObject(SCAudioPlayer(sc))
        }
            
    }
}
