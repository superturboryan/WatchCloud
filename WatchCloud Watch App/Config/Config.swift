//
//  Config.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-09-07.
//

import Foundation
import SwiftUI

enum Config {
    
    static let apiUrl = "https://api.soundcloud.com/"
    
    static func isDownloadingEnabled(for id: Int?) -> Bool {
        guard let id else { return false }
        return [
            199092249, // SuperTurboRyan
            303454728, // romandavidgarcia
        ].contains(id)
    }
    
    static let isTestEnvironment = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    // NSClassFromString("XCTestCase") != nil
    
    // MARK: - 🌏 Localization Helpers
    static let isObjectFirstLanguage =
    String(Locale.preferredLanguages[0].prefix(2)) == Locale(identifier: "ko").language.languageCode?.identifier
    || String(Locale.preferredLanguages[0].prefix(2)) == Locale(identifier: "ja").language.languageCode?.identifier
    
    static let isRightToLeftLanguage = Locale.current.language.characterDirection == .rightToLeft
    
    // MARK: - 🛠️ Loaded from config.xcconfig
    static let clientId = Bundle.main.object(forInfoDictionaryKey: "SC_CLIENT_ID") as! String
    static let clientSecret = Bundle.main.object(forInfoDictionaryKey: "SC_CLIENT_SECRET") as! String
    static let redirectURI = Bundle.main.object(forInfoDictionaryKey: "SC_REDIRECT_URI") as! String
    static let mpProjectToken = Bundle.main.object(forInfoDictionaryKey: "MP_PROJECT_TOKEN") as! String
    
    // MARK: - 💾 Loaded from UserDefaults
    @AppStorage("allowDownloadingUsingData") static var allowDownloadingUsingData = false
    @AppStorage("showQRWhenWatchIsDimmed") static var showQRWhenWatchIsDimmed = false
}
