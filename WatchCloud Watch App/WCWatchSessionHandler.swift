//
//  WCSessionHandler.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-11-30.
//

import Foundation
import SoundCloud
import WatchConnectivity

class WCWatchSessionHandler: NSObject, WCSessionDelegate {
    
    static let shared = WCWatchSessionHandler()
    private let session = WCSession.default
    
    override init() {
        super.init()
        if !WCSession.isSupported() {
            fatalError()
        }
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WCSession activated successfully? \(activationState == .activated)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let tokenData = message["\(TokenResponse.self)"] as? Data {
            NotificationCenter.default.post(name: .newAuthTokens, object: tokenData)
        } else {
            print("Received unexpected message from iOS app: \(message)")
        }
    }
}

