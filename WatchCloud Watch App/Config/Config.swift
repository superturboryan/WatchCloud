//
//  Config.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-09-07.
//

import Foundation

struct Config {
    private init() {}
    
    static let isTestEnvironment = NSClassFromString("XCTestCase") != nil
    
    static let apiUrl = "https://api.soundcloud.com/"
    static let clientId = Bundle.main.object(forInfoDictionaryKey: "SC_CLIENT_ID") as! String
    static let clientSecret = Bundle.main.object(forInfoDictionaryKey: "SC_CLIENT_SECRET") as! String
    static let redirectURI = Bundle.main.object(forInfoDictionaryKey: "SC_REDIRECT_URI") as! String
    
    static let mpProjectToken = Bundle.main.object(forInfoDictionaryKey: "MP_PROJECT_TOKEN") as! String
    
    static func isDownloadingEnabled(for id: Int?) -> Bool {
        guard let id else {
            return false
        }
        return superID.contains(id)
    }
    private static let superID = [
        199092249, // SuperTurboRyan
    ]
    
    static let isObjectFirstLanguage =
    String(Locale.preferredLanguages[0].prefix(2)) == Locale(identifier: "ko").language.languageCode?.identifier
    || String(Locale.preferredLanguages[0].prefix(2)) == Locale(identifier: "ja").language.languageCode?.identifier
    
    static let isRightToLeft = Locale.current.language.characterDirection == .rightToLeft
}
