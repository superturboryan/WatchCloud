//
//  PlayerOptionsView.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on spacing23-08-31.
//

import SoundCloud
import SwiftUI

struct PlayerOptionsView: View {
    
    @EnvironmentObject var sc: SoundCloud
    @Environment(\.dismiss) var dismiss
    
    @Binding var track: Track
    
    let hSpacing: CGFloat = 12
    
    var body: some View {
        VStack(spacing: 36) {
            HStack(spacing: hSpacing) {
                likeButton.disabled(false)
                downloadButton.disabled(!Config.isDownloadingEnabled(for: sc.myUser?.id))
            }
            HStack(spacing: hSpacing) {
                addToPlaylistButton.disabled(true)
                shareButton.disabled(false)
            }
        }
        .toolbar { closeToolbarButton }
        .fontDesign(.rounded)
        .buttonStyle(.plain)
    }
    
    var likeButton: some View {
        Button { tappedLike() } label: {
            buttonView(
                track.userFavorite ? "heart.fill" : "heart",
                .pink,
                track.userFavorite ? "Unlike" : "Like"
            )
        }
    }
    
    var downloadButton: some View {
        Button { tappedDownload() } label: {
            downloadButtonView()
        }
    }
    
    var addToPlaylistButton: some View {
        Button {} label: {
            buttonView("plus", .scOrange, "Add")
        }
    }
    
    var shareButton: some View {
        ShareLink(item: URL(string: track.permalinkUrl)!) {
            buttonView("square.and.arrow.up", .blue, "Share")
        }
    }
    
    var closeToolbarButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Close") { dismiss() }
        }
    }
    
    
    func tappedLike() {
        Haptics.click()
        Task {
            if track.userFavorite { try await sc.unlikeTrack(track) }
            else { try await sc.likeTrack(track) }
            track.userFavorite.toggle()
        }
    }
    
    func tappedDownload() {
        Haptics.click()
        Task {
            // TODO: Handle errors
            if isTrackDownloaded { try sc.removeDownload(track) }
            else { try await sc.download(track) }
        }
    }
    
    var isTrackDownloaded: Bool {
        sc.downloadedTracks.contains(where: { $0.id == track.id })
    }
    
    var isTrackDownloading: Bool {
        sc.downloadsInProgress.keys.contains(track)
    }
    
    // MARK: - UI Helpers
    func buttonView(_ name: String, _ color: Color, _ text: String) -> some View {
        Image(systemName: name)
            .resizable()
            .scaledToFit()
            .font(Font.title.weight(.medium))
            .padding(.vertical, 10)
            .frame(width: 76, height: 45)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .clipShape(Capsule(style: .continuous))
            .overlay {
                Text(text)
                    .lineLimit(1)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .offset(y: 34)
                    .minimumScaleFactor(0.8)
            }
    }
    
    func downloadButtonView() -> some View {
        Image(systemName: isTrackDownloaded ? "arrow.down.circle.fill" : "arrow.down.circle")
            .resizable()
            .scaledToFit()
            .font(Font.title.weight(.medium))
            .spinAnimation(isTrackDownloading)
            .padding(.vertical, 10)
            .frame(width: 76, height: 45)
            .background(Color.green.opacity(0.2))
            .foregroundColor(Color.green)
            .clipShape(Capsule(style: .continuous))
            .overlay {
                Text(isTrackDownloading ? "Downloading" : (isTrackDownloaded ? "Downloaded" : "Download"))
                    .lineLimit(1)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .offset(y: 34)
                    .minimumScaleFactor(0.8)
            }
    }
}

struct PlayerOptionsView_Previews: PreviewProvider {
    static var track = testTrack()
    static var trackBinding = Binding(get: { track }, set: { _ in })
    
    static var previews: some View {
        PlayerOptionsView(track: trackBinding)
            .environmentObject({ () -> SoundCloud in
                testSC.myUser = testUser
                testSC.downloadsInProgress = [track : Progress.with(0.69)]
                return testSC
            }())
    }
}
