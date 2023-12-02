//
//  WCSessionHandler.swift
//  WatchCloud Login
//
//  Created by Ryan Forsyth on 2023-11-30.
//

import Combine
import Foundation
import OSLog
import SoundCloud
import WatchConnectivity

class WCPhoneSessionHandler: NSObject, WCSessionDelegate {
    
    static let shared = WCPhoneSessionHandler()
    
    var isWatchAppInstalled = CurrentValueSubject<Bool, Never>(false)
    
    private let session = WCSession.default
    private let encoder = JSONEncoder()
    private var subscriptions = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupSession()
        observeSessionProperties()
    }
    
    private func setupSession() {
        guard WCSession.isSupported() else {
            Logger.wcPhoneSessionHandler.critical("WCSession is not supported")
            return
        }
        session.delegate = self
        session.activate()
    }
    
    private func observeSessionProperties() {
        session.publisher(for: \.isWatchAppInstalled)
            .assign(to: \.value, on: isWatchAppInstalled)
            .store(in: &subscriptions)
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
        do {
            let message = ["\(TokenResponse.self)" : encodedTokens]
            try session.updateApplicationContext(message)
        } catch {
            Logger.wcPhoneSessionHandler.error("Failed to TokenResponse to watch")
        }
    }
}
