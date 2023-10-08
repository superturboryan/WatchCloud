//
//  PlaylistSummaryView.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-07.
//

import SoundCloud
import SwiftUI

struct PlaylistSummaryView: View {
    
    @Binding var playlist: Playlist
    @Binding var isLiked: Bool
    var isLikeable: Bool = true
    let tappedPlayAll: () -> Void
    let tappedLike: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                let size = CGSize(width: Device.screenSize.width / 2.5, height: Device.screenSize.width / 2.5)
                CachedImageView(url: playlist.largerArtworkUrlWithTrackAndUserFallback.absoluteString)
                    .size(size)
                playAllButton
                    .size(size)
            }
            
            playlistInfoLabels
            
            HStack(spacing: 4) {
                shareButton
                likeButton.disabled(!isLikeable)
            }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var playlistInfoLabels: some View {
        let trackCount = playlist.trackCount == 0 ? (playlist.tracks?.count ?? 0) : playlist.trackCount
        let trackCountText = String(localized: "%d tracks", defaultValue: "\(trackCount) tracks")
        let durationText = playlist.durationInSeconds.hoursAndMinutesStringFromSeconds
        
        VStack(spacing: 0) {
            Text(verbatim: playlist.title)
                .font(.headline)
            HStack {
                Text(trackCountText)
                Text(verbatim: "-")
                Text(durationText)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.9)
    }
    
    private var playAllButton: some View {
        Button {
            tappedPlayAll()
        } label: {
            Image(systemName: "play.square.stack")
            .resizable()
            .symbolRenderingMode(.palette)
            .foregroundStyle(LinearGradient.scOrange(.horizontal), .white)
            .scaledToFit()
            .scaleEffect(0.9)
        }
        .disabled(playlist.tracks.isEmptyOrNil)
    }
    
    private var shareButton: some View {
        ShareLink(item: URL(string: playlist.permalinkUrl)!) {
            Image(systemName: "square.and.arrow.up")
                .resizable()
                .scaledToFit()
                .padding(6)
                .size(CGSize(width: (Device.screenSize.width - 10) / 2, height: 40))
                .fontWeight(.semibold)
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.blue)
                .cornerRadius(8)
        }
    }
    
    private var likeButton: some View {
        Button { tappedLike() } label: {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .resizable()
                .scaledToFit()
                .symbolReplaceEffect()
                .padding()
                .size(CGSize(width: (Device.screenSize.width - 10) / 2, height: 40))
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.pink)
                .cornerRadius(8)
        }
        .disabled(playlist.tracks.isEmptyOrNil)
    }
}

@available(watchOS 10, *)
#Preview(traits: .sizeThatFitsLayout) {
    PlaylistSummaryView(
        playlist: .constant(testPlaylist()),
        isLiked: .constant(true),
        tappedPlayAll: {}, 
        tappedLike: {}
    )
}
