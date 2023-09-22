//
//  PoweredBySCView.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-09-22.
//

import SwiftUI

struct PoweredBySCView: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("powered by")
                .font(.system(size: 12, weight: .medium, design: .rounded))

            Image.scLogoVertical
                .resizable()
                .scaledToFit()
                .frame(height: 34)
        }
    }
}

@available(watchOS 10, *)
#Preview(traits: .sizeThatFitsLayout) {
    PoweredBySCView()
        .padding()
}
