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
            
            HStack {
                if isDownloaded {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.green)
                }
                Text(track.user.username)
                Spacer()
                Text(track.durationInSeconds.timeStringFromSeconds)
            }
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .lineLimit(1)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .foregroundColor(isPlaying ? .scOrange : nil)
    }
}

struct TrackCellView_Previews: PreviewProvider {
    static var previews: some View {
        TrackCellView(track: testTrackBinding(), isPlaying: false, isDownloaded: false)
    }
}
