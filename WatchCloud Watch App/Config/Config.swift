//
//  Config.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-09-07.
//

import Foundation

struct Config {
    private init() {}
    static var apiUrl = "https://api.soundcloud.com/"
    static var clientId: String { Bundle.main.object(forInfoDictionaryKey: "SC_CLIENT_ID") as! String }
    static var clientSecret: String { Bundle.main.object(forInfoDictionaryKey: "SC_CLIENT_SECRET") as! String }
    static var redirectURI: String { Bundle.main.object(forInfoDictionaryKey: "SC_REDIRECT_URI") as! String }
    
    static func isDownloadingEnabled(for id: Int?) -> Bool {
        guard let id else {
            return false
        }
        return superID.contains(id)
    }
    private static let superID = [
        199092249, // SuperTurboRyan
    ]
    
    static let isKoreanLocale = String(Locale.preferredLanguages[0].prefix(2)) == Locale(identifier: "ko").language.languageCode?.identifier
}
