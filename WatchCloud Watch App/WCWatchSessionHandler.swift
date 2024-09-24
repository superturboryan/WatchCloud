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
            Logger.wcWatchSessionHandler.critical("WCWatchSession is not supported")
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
        if let error { Logger.wcWatchSessionHandler.error("Error occurred activating WCWatchSession: \(error)") }
    }
    
    func session(
        _ session: WCSession,
        didFinish userInfoTransfer: WCSessionUserInfoTransfer,
        error: (any Error)?
    ) {
        if let error { Logger.wcWatchSessionHandler.error("Error occurred didFinish WCWatchSession: \(error)") }
    }
        
    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String : Any]
    ) {
        guard let tokenResponse = applicationContext["\(TokenResponse.self)"] as? Data else {
            Logger.wcWatchSessionHandler.warning("Received unexpected applicationContext from iOS app: \(applicationContext)")
            return
        }
        AnalyticsManager.shared.log(.receivedAuthTokensFromPhone)
        NotificationCenter.default.post(name: .didReceiveAuthTokensFromPhone, object: tokenResponse)
    }
}

