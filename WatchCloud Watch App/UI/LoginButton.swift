//
//  LoginButton.swift
//  WatchCloud
//
//  Created by Ryan Forsyth on 2023-12-02.
//

import SwiftUI

struct LoginButton: View {
    
    var didTap: () -> Void
    
    var body: some View {
        Button { didTap() } label: {
            Label(String(localized: "Connect", comment: "Verb"), systemImage: "cloud.fill")
                .lineLimit(1)
                .fontWeight(.semibold)
                .minimumScaleFactor(0.7)
        }
        .font(.title3)
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(.white.opacity(0.12))
        .overlay {
            Capsule()
                .strokeBorder(style: StrokeStyle(lineWidth: 6))
                .foregroundStyle(LinearGradient.scOrange(.horizontal))
        }
        .clipShape(Capsule())
    }
}

#Preview {
    LoginButton { }
}
