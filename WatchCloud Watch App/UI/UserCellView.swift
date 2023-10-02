//
//  UserCellView.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-02.
//

import SoundCloud
import SwiftUI

struct UserCellView: View {
    @Binding var user: User
    
    var body: some View {
        HStack(spacing: 8) {

            CachedImageView(url: user.avatarUrl)
                .frame(width: 30, height: 30)

            Text(verbatim: user.username)

            Spacer()
        }
        .lineLimit(1)
        .padding(10)
        .background(.secondary.opacity(0.2))
        .cornerRadius(10)
    }
}

@available(watchOS 10, *)
#Preview(traits: .sizeThatFitsLayout) {
    UserCellView(user: .constant(testUser()))
}
