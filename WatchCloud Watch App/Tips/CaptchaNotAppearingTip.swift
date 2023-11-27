//
//  CaptchaNotAppearingTip.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-09.
//

import TipKit

@available(watchOS 10, *)
struct CaptchaNotAppearingTip: Tip {
    
    var title: Text {
        Text(String(localized: "Trouble signing in?", comment: "Tip title"))
            .font(.footnote)
            .fontWeight(.medium)
    }
    var message: Text? {
        Text(String(localized: "If captcha is not appearing on SoundCloud login page, try using", comment: "Tip message"))
            .fontDesign(.rounded)
        + Text(verbatim: "\n")
        + Text(String(localized: "Sign in with Google", comment: "Tip message"))
            .fontWeight(.bold)
            .fontDesign(.rounded)
    }
    var image: Image? { // Doesn't show on watchOS?
        Image(systemName: "exclamationmark.triangle")
    }
    
    var rules: [Rule] {[
        #Rule(LoginView.$hasTriedToLoginAndCancelled) { $0 == true },
    ]}
}
