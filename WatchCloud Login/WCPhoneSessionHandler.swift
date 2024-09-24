//
//  WCSessionHandler.swift
//  WatchCloud Login
//
//  Created by Ryan Forsyth on 2023-11-30.
//

import Combine
import OSLog
import SoundCloud
import WatchConnectivity

class WCPhoneSessionHandler: NSObject, WCSessionDelegate {
    
    static let shared = WCPhoneSessionHandler()
    
    var isWatchAppInstalled: AnyPublisher<Bool, Never> = CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    
    private let session = WCSession.default
    private let encoder = JSONEncoder()
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        guard WCSession.isSupported() else {
            Logger.wcPhoneSessionHandler.critical("WCPhoneSession is not supported")
            return
        }
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        guard error == nil else {
            Logger.wcPhoneSessionHandler.error("Error occurred activating WCPhoneSession: \(error)")
            return
        }
        isWatchAppInstalled = session.publisher(for: \.isWatchAppInstalled)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        Logger.wcPhoneSessionHandler.warning("WCPhoneSession sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        Logger.wcPhoneSessionHandler.warning("WCPhoneSession sessionDidDeactivate")
    }
    
    func send(_ authTokens: TokenResponse) {
        do {
            let encodedTokens = try encoder.encode(authTokens)
            let message = ["\(TokenResponse.self)" : encodedTokens]
            try session.updateApplicationContext(message)
        } catch {
            Logger.wcPhoneSessionHandler.error("Failed to send auth tokens: \(error)")
        }
    }
}
