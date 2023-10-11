//
//  PlaylistCellView.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-05.
//

import SoundCloud
import SwiftUI

struct PlaylistCellView: View {
    @Binding var playlist: Playlist
    
    var body: some View {
        HStack(spacing: 8) {
            CachedImageView(url: playlist.largerArtworkUrlWithTrackAndUserFallback)
                .frame(width: 30, height: 30)

            VStack(alignment: .leading) {
                Text(verbatim: playlist.title)
                    .minimumScaleFactor(0.8)
                
                Text(String(localized: "%d tracks", defaultValue: "\(playlist.trackCount) tracks"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .lineLimit(1)
        .padding([.vertical, .leading], 10)
        .padding(.trailing, 2)
        .background(.secondary.opacity(0.2))
        .cornerRadius(10)
    }
}

#Preview {
    PlaylistCellView(playlist: .constant(testPlaylist()))
}
