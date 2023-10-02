//
//  UserList.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-02.
//

import SoundCloud
import SwiftUI

struct UserList: View {
    
    @Binding var users: [User]
    @Binding var canLoadMore: Bool
    let title: String
    var reachedBottomOfList: (() -> Void)? = nil
    
    var body: some View {
        List {
            ForEach($users, id: \.id) { user in
                HStack(spacing: 8) {
                    CachedImageView(url: user.wrappedValue.avatarUrl)
                        .frame(width: 30, height: 30)
                    Text(verbatim: user.wrappedValue.username)
                }
            }
            if canLoadMore, let reachedBottomOfList {
                userListLoadingView.onAppear {
                    reachedBottomOfList()
                }
            } else {
                sectionFooterView(String(localized: "End of list"))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(title)
    }
    
    var userListLoadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
                .tint(.scOrange)
            Text("Loading users...")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    NavigationStack {
        UserList(
            users: .constant([testUser]),
            canLoadMore: .constant(false),
            title: "Following"
        )
    }
}
