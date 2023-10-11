//
//  MixpanelAnalyticsService.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-08.
//

import Mixpanel

final class MixpanelAnalyticsService {
    
    private let service = Mixpanel.initialize(token: Config.mpProjectToken)
    
    init() {
        #if DEBUG
//        service.loggingEnabled = true
        service.optOutTracking()
        #endif
    }
}

extension MixpanelAnalyticsService: AnalyticsService {
    func sendEvent(_ name: String, with properties: [String : String]? = nil) {
        service.track(event: name, properties: properties)
    }
}
