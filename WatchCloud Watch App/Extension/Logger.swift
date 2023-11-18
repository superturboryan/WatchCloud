//
//  Logger.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-20.
//

import OSLog

extension Logger {
    
    static let subsystem = Bundle.main.bundleIdentifier!
    
    static let audioPlayer = Logger(subsystem: subsystem, category: "AudioPlayer")
    
    static let rootView = Logger(subsystem: subsystem, category: "RootView")
}
