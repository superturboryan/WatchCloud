//
//  NowPlayingInfo.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-11-20.
//

import SoundCloud

struct NowPlayingInfo: Codable {
    let progress: Double
    var track: Track
    var queue: [Track]
}
