//
//  WCSessionHandler.swift
//  WatchCloud Login
//
//  Created by Ryan Forsyth on 2023-11-30.
//

import Foundation
import OSLog
import SoundCloud
import WatchConnectivity

class WCPhoneSessionHandler: NSObject, WCSessionDelegate {
    
    static let shared = WCPhoneSessionHandler()
    private let session = WCSession.default
    private let encoder = JSONEncoder()
    
    private var transfer: WCSessionUserInfoTransfer?
    
    override init() {
        super.init()
        setupSession()
        observeTransfer()
    }
    
    private func setupSession() {
        guard WCSession.isSupported() else {
            Logger.wcPhoneSessionHandler.critical("WCSession is not supported")
            return
        }
        session.delegate = self
        session.activate()
    }
    
    private func observeTransfer() {
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WCSession activated successfully? \(activationState == .activated)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func send(_ authTokens: TokenResponse) {
        guard let encodedTokens = try? encoder.encode(authTokens) else {
            return
        }
        let message = ["\(TokenResponse.self)" : encodedTokens]
        do {
            try session.updateApplicationContext(message)
        } catch {
            Logger.wcPhoneSessionHandler.error("Failed to TokenResponse to watch")
        }
    }
}
