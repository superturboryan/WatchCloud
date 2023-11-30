//
//  WCSessionHandler.swift
//  WatchCloud Login
//
//  Created by Ryan Forsyth on 2023-11-30.
//

import Foundation
import SoundCloud
import WatchConnectivity

class WCPhoneSessionHandler: NSObject, WCSessionDelegate {
    
    static let shared = WCPhoneSessionHandler()
    private let session = WCSession.default
    private let encoder = JSONEncoder()
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
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
        session.sendMessage(message, replyHandler: nil)
    }
}
