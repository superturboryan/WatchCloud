//
//  WCSessionHandler.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-11-30.
//

import Foundation
import WatchConnectivity

class WCSessionHandler: NSObject, WCSessionDelegate {
    
    static let shared = WCSessionHandler()
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
        print("Message from iOS app: \(message)")
    }
}

