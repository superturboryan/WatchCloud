//
//  AnalyticsManager.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-08.
//

protocol AnalyticsService: AnyObject {
    func sendEvent(_ name: String, with properties: [String : String]?)
}

final class AnalyticsManager {
    
    static let shared = AnalyticsManager(MixpanelAnalyticsService())
    
    private let service: AnalyticsService
    
    init(_ service: AnalyticsService) {
        self.service = service
    }
    
    func log(_ event: AnalyticsEvent) {
        service.sendEvent(
            event.name,
            with: event.metadata
        )
    }
}
