//
//  NowPlayingInfo.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-11-20.
//

import SoundCloud

struct NowPlayingInfo: Codable {
    let progress: Double
    let track: Track
    let queue: [Track]
}
