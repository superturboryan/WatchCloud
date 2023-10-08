//
//  MixpanelAnalyticsService.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-08.
//

import Mixpanel

final class MixpanelAnalyticsService {
    
    private let service = Mixpanel.mainInstance()
    
    private init() {
        Mixpanel.initialize(token: Config.mpProjectToken)
        service.trackAutomaticEventsEnabled = true
    }
}

extension MixpanelAnalyticsService: AnalyticsService {
    func sendEvent(_ name: String, with properties: [String : String]? = nil) {
        service.track(event: name, properties: properties)
    }
}
