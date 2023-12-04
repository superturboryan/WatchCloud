//
//  DebugAnalyticsService.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-09.
//

import Foundation
import OSLog

final class DebugAnalyticsService {
    
    var eventsLogged: [(String, [String: String]?)] = []
    var shouldPrint = true
    
    init(shouldPrint: Bool = true) {
        self.shouldPrint = shouldPrint
    }
}

extension DebugAnalyticsService: AnalyticsService {
    func sendEvent(_ name: String, with properties: [String : String]?) {
        eventsLogged.append((name, properties))
        if shouldPrint {
            Logger.analytics.notice("📊 \(name)")
        }
    }
}

fileprivate extension Logger {
    static let analytics = Logger(subsystem: subsystem, category: "Debug Analytics")
}
