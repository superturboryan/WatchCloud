//
//  MixpanelAnalyticsService.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-08.
//

import Mixpanel

final class MixpanelAnalyticsService {
    
    init() {
        Mixpanel.initialize(token: Config.mpProjectToken)
        #if DEBUG
//        Mixpanel.mainInstance().loggingEnabled = true
        Mixpanel.mainInstance().optOutTracking()
        #endif
        Mixpanel.mainInstance().trackAutomaticEventsEnabled = true
    }
}

extension MixpanelAnalyticsService: AnalyticsService {
    func sendEvent(_ name: String, with properties: [String : String]? = nil) {
        Mixpanel.mainInstance().track(event: name, properties: properties)
    }
}
