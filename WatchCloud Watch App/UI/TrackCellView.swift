//
//  TrackCellView.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-08-31.
//

import SoundCloud
import SwiftUI

struct TrackCellView: View {
    @Binding var track: Track
    let isPlaying: Bool
    let isDownloaded: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(track.title)
            
            HStack(spacing: 4) {
                if isDownloaded {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.green)
                }
                Text(track.user.username)
                Spacer()
                Text(track.durationInSeconds.timeStringFromSeconds)
            }
            .font(.footnote)
            .foregroundColor(.primary.opacity(0.7))
        }
        .lineLimit(1)
        .padding(10)
        .foregroundColor(isPlaying ? .scOrange : nil)
        .background(.secondary.opacity(0.2))
        .cornerRadius(10)
    }
}

struct TrackCellView_Previews: PreviewProvider {
    static var previews: some View {
        TrackCellView(
            track: testTrackBinding(),
            isPlaying: false,
            isDownloaded: true
        )
        .previewLayout(.sizeThatFits)
    }
}
