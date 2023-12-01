//
//  Logger.swift
//  WatchCloud Login
//
//  Created by Ryan Forsyth on 2023-12-01.
//

import OSLog

extension Logger {
    
    static let subsystem = Bundle.main.bundleIdentifier!
    
    static let wcPhoneSessionHandler = Logger(subsystem: subsystem, category: "WCPhoneSessionHandler")
}
