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
    
    static let audioStore = Logger(subsystem: subsystem, category: "AudioStore")
    
    static let downloadsView = Logger(subsystem: subsystem, category: "DownloadsView")
    static let rootView = Logger(subsystem: subsystem, category: "RootView")
    static let userView = Logger(subsystem: subsystem, category: "UserView")
    
    static let wcWatchSessionHandler = Logger(subsystem: subsystem, category: "WCWatchSessionHandler")
}
