//
//  DebugAnalyticsService.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-09.
//

import Foundation

final class DebugAnalyticsService {
    private var eventsLogged: [(String, [String: String]?)] = []
    public var shouldPrint = true
    
    init(shouldPrint: Bool = true) {
        self.shouldPrint = shouldPrint
    }
}

extension DebugAnalyticsService: AnalyticsService {
    func sendEvent(_ name: String, with properties: [String : String]?) {
        eventsLogged.append((name, properties))
        if shouldPrint {
            print("🎯 logged \(name)")
        }
        if shouldPrint && name == "\(AnalyticsEvent.appBackground)" {
            dumpEvents()
        }
    }
    
    func dumpEvents() {
        print("\n🧐 analytics events since launch:")
        for event in eventsLogged {
            print("\(event.0) \(event.1 != nil ? ": \(event.1!)" : "")")
        }
    }
}
