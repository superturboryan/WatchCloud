//
//  TrackCellView.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-08-31.
//

import SoundCloud
import SwiftUI

struct TrackCellView: View {
    
    let track: Track
    let isPlaying: Bool
    let isDownloaded: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(verbatim: track.title)
            
            HStack(spacing: 4) {
                if isDownloaded {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.green)
                }
                Text(verbatim: track.user.username)
                Spacer()
                Text(verbatim: track.durationInSeconds.timeStringFromSeconds)
            }
            .font(.footnote)
            .foregroundColor(.primary.opacity(0.7))
        }
        .lineLimit(1)
        .padding(10)
        .foregroundColor(isPlaying ? .scOrange : nil)
        .background(Color.cellBG)
        .cornerRadius(10)
    }
}

@available(watchOS 10, *)
#Preview(traits: .sizeThatFitsLayout) {
    TrackCellView(
        track: testTrack(),
        isPlaying: false,
        isDownloaded: true
    )
}
