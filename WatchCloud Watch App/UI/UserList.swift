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
        ScrollView {
            LazyVStack {
                ForEach($users, id: \.id) { user in
                    NavigationLink {
                        Text("Detail view: \(user.wrappedValue.username)")
                    } label: {
                        UserCellView(user: user)
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
            .animation(.default, value: users)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(title)
        .buttonStyle(.plain)
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
            users: .constant([testUser(), testUser(), testUser(), testUser(), testUser()]),
            canLoadMore: .constant(false),
            title: "Following"
        )
    }
}
