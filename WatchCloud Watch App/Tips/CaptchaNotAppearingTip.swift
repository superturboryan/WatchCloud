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
        Text(String(localized: "Trouble signing in?", comment: "Tip title")).font(.footnote).fontWeight(.medium)
    }
    var message: Text? {
        Text(verbatim: "\n")
        + Text("If captcha is not appearing, try using").fontDesign(.rounded)
        + Text(verbatim: "\n\n")
        + Text("Sign in with Google").fontWeight(.bold).fontDesign(.rounded)
    }
    var image: Image? { // Doesn't show on watchOS?
        Image(systemName: "exclamationmark.triangle")
    }
    
    var rules: [Rule] {[
        #Rule(LoginView.$hasTriedToLoginAndCancelled) { $0 == true },
    ]}
}
