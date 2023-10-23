//
//  UserList.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-02.
//

import SoundCloud
import SwiftUI

struct UserListView: View {
    
    @Binding var users: [User]
    @Binding var canLoadMore: Bool
    
    let title: String
    var sortedAlphabetically = true
    var reachedBottomOfList: (() -> Void)? = nil
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach( $users.sorted(by: { sortedAlphabetically ? $0.wrappedValue.username < $1.wrappedValue.username : false }), id: \.wrappedValue.id) { user in
                    NavigationLink {
                        UserView(user: user.wrappedValue).onAppear {
                            AnalyticsManager.shared.log(.tappedUser)
                        }
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
        UserListView(
            users: .constant([testUser(), testUser(), testUser(), testUser(), testUser()]),
            canLoadMore: .constant(false),
            title: "Following"
        )
    }
}
