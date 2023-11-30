//
//  WCSessionHandler.swift
//  WatchCloud Login
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
        print("activationDidCompleteWith state \(activationState)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
}
