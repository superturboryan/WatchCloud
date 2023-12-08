//
//  WCSessionHandler.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-11-30.
//

import Foundation
import OSLog
import SoundCloud
import WatchConnectivity

class WCWatchSessionHandler: NSObject, WCSessionDelegate {
    
    static let shared = WCWatchSessionHandler()
    private let session = WCSession.default
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        guard WCSession.isSupported() else {
            Logger.wcWatchSessionHandler.critical("WCSession is not supported")
            return
        }
        session.delegate = self
        session.activate()
    }
    
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error { Logger.wcWatchSessionHandler.error("Error occurred activating WCSession: \(error)") }
    }
        
    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String : Any]
    ) {
        if let tokenData = applicationContext["\(TokenResponse.self)"] as? Data {
            AnalyticsManager.shared.log(.receivedAuthTokensFromPhone)
            NotificationCenter.default.post(name: .didReceiveAuthTokensFromPhone, object: tokenData)
        } else {
            Logger.wcWatchSessionHandler.error("Received unexpected applicationContext from iOS app: \(applicationContext)")
        }
    }
}

