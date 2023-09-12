//
//  Config.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-09-07.
//

import Foundation

struct Config {
    private init() {}
    static var clientId: String { Bundle.main.object(forInfoDictionaryKey: "SC_CLIENT_ID") as! String }
    static var clientSecret: String { Bundle.main.object(forInfoDictionaryKey: "SC_CLIENT_SECRET") as! String }
    static var redirectURI: String { Bundle.main.object(forInfoDictionaryKey: "SC_REDIRECT_URI") as! String }
}
