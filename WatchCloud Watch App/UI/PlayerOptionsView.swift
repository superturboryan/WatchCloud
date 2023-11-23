//
//  PlayerOptionsView.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on spacing23-08-31.
//

import SoundCloud
import SwiftUI

struct PlayerOptionsView: View {
    
    @EnvironmentObject var audioStore: AudioStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var player: AudioPlayer
    
    @Binding var track: Track
    
    private let hSpacing: CGFloat = 12
    private let buttonSize = CGSize(width: 76, height: 45)
    private let labelYOffset: CGFloat = 36
    
    private var isDownloadingEnabled: Bool {
        Config.isDownloadingEnabled(for: userStore.myUser?.id)
    }
    
    var body: some View {
        VStack(spacing: 32) {
            HStack(spacing: hSpacing) {
                likeButton
                downloadButton
                    .disabled(!isDownloadingEnabled)
                    .opacity(isDownloadingEnabled ? 1 : 0)
            }
            HStack(spacing: hSpacing) {
                playbackSpeedButton
                shareButton
            }
        }
        .padding(.bottom, 10)
        .fontDesign(.rounded)
        .buttonStyle(.plain)
        .fullWidthAndHeight()
        .background(.black)
    }
    
    var likeButton: some View {
        Button { tappedLike() } label: {
            buttonView(
                audioStore.isLiked(track) ? "heart.fill" : "heart",
                .pink,
                audioStore.isLiked(track) ? String(localized: "Liked", comment: "Adjective") : String(localized: "Like", comment: "Verb")
            )
        }
    }
    
    var downloadButton: some View {
        Button { tappedDownload() } label: {
            downloadButtonView()
        }
    }
    
    var playbackSpeedButton: some View {
        Button { player.cyclePlaybackSpeed() } label: {
            playbackSpeedView
        }
    }
    
    var shareButton: some View {
        ShareLink(item: URL(string: track.permalinkUrl)!) {
            buttonView("square.and.arrow.up", .blue, String(localized: "Share"))
        }
    }
    
    func tappedLike() {
        Haptics.click()
        AnalyticsManager.shared.log(.tappedLikeTrack)
        
        Task {
            try await audioStore.toggleLikedTrack(track)
        }
    }
    
    func tappedDownload() {
        Haptics.click()
        Task {
            if isTrackDownloaded {
                #warning("Errors not handled")
                try audioStore.removeDownload(track)
            } else {
                try await audioStore.download(track)
            }
        }
    }
    
    var isTrackDownloaded: Bool {
        audioStore.downloadedTracks.contains(where: { $0.id == track.id })
    }
    
    var isTrackDownloading: Bool {
        audioStore.downloadsInProgress.keys.contains(track)
    }
    
    // MARK: - UI Helpers
    func buttonView(_ name: String, _ color: Color, _ text: String) -> some View {
        ZStack {
            Image(systemName: name)
                .resizable()
                .scaledToFit()
                .symbolReplaceEffect(2.0)
                .fontWeight(.semibold)
                .padding(.vertical, 9)
                .size(buttonSize)
                .background(color.opacity(0.2))
                .foregroundColor(color)
                .clipShape(Capsule(style: .continuous))
                .overlay {
                    Text(verbatim: text)
                        .opacity(0.9)
                        .lineLimit(1)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .offset(y: labelYOffset)
                        .minimumScaleFactor(0.8)
                }
        }
    }
    
    @ViewBuilder
    var playbackSpeedView: some View {
        ZStack {
            Color.scOrange.opacity(0.2)
            Text(verbatim: player.selectedPlaybackSpeed.displayable)
                .font(.system(size: 28, weight: .semibold))
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 9)
                .foregroundStyle(LinearGradient.scOrange(.vertical))
                .animation(.default, value: player.selectedPlaybackSpeed)
        }
        .size(buttonSize)
        .fixedSize()
        .clipShape(Capsule(style: .continuous))
        .overlay {
            Text("Speed")
                .opacity(0.9)
                .lineLimit(1)
                .font(.footnote)
                .fontWeight(.medium)
                .offset(y: labelYOffset)
                .minimumScaleFactor(0.8)
        }
    }
    
    func downloadButtonView() -> some View {
        Image(systemName: isTrackDownloaded ? "arrow.down.circle.fill" : "arrow.down.circle")
            .resizable()
            .scaledToFit()
            .fontWeight(.semibold)
            .spinAnimation(isTrackDownloading)
            .padding(.vertical, 10)
            .size(buttonSize)
            .background(Color.green.opacity(0.2))
            .foregroundColor(Color.green)
            .clipShape(Capsule(style: .continuous))
            .overlay {
                Text(isTrackDownloading ?
                     String(localized: "Downloading") : (isTrackDownloaded ?
                                      String(localized: "Downloaded", comment: "Past participle") :
                                      String(localized: "Download", comment: "Verb")))
                    .opacity(0.9)
                    .lineLimit(1)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .offset(y: labelYOffset)
                    .minimumScaleFactor(0.8)
            }
    }
}

extension AudioPlayer.PlaybackSpeed {
    var numDecimalToDisplay: Int {
        switch self {
        case .ThreeQuarters: 2
        case .One: 0
        case .OneAndAQuarter: 2
        case .OnePointFive: 1
        case .OneAndThreeQuarters: 2
        case .Double: 0
        }
    }
    
    var displayable: String {
        "\(String(format: "%.\(numDecimalToDisplay)f", rawValue))x"
    }
}

#Preview {
    let track = testTrack()
    let trackBinding = Binding(get: { track }, set: { _ in })
    
    return PlayerOptionsView(track: trackBinding)
        .environmentObject(AudioStore(testSC))
        .environmentObject(UserStore(testSC))
        .environmentObject(testAudioPlayer)
}
