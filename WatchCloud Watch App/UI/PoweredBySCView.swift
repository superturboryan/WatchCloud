//
//  PoweredBySCView.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-09-22.
//

import SwiftUI

struct PoweredBySCView: View {
    
    let title = String(localized: "powered by", comment: "Used next to SC logo")
    
    var body: some View {
        VStack(spacing: 4) {
            if !Config.isObjectFirstLanguage {
                Text(title)
            }
            Image.scLogoVertical
                .resizable()
                .scaledToFit()
                .frame(height: 34)
            if Config.isObjectFirstLanguage {
                Text(title)
            }
        }
        .font(.system(size: 12, weight: .medium, design: .rounded))
    }
}

@available(watchOS 10, *)
#Preview(traits: .sizeThatFitsLayout) {
    PoweredBySCView()
        .padding()
}
