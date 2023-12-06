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
    
    var sortedUsers: Array<Binding<User>> {
        $users.sorted(by: { sortedAlphabetically ? $0.wrappedValue.username < $1.wrappedValue.username : false })
    }
    
    var body: some View {
        List {
            ForEach(sortedUsers, id: \.wrappedValue.id) { user in
                NavigationLink {
                    UserView(user: user.wrappedValue).onAppear {
                        AnalyticsManager.shared.log(.tappedUser)
                    }
                } label: {
                    UserCellView(user: user)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            Group {
                if canLoadMore, let reachedBottomOfList {
                    userListLoadingView.onAppear {
                        reachedBottomOfList()
                    }
                } else if !canLoadMore, users.isEmpty {
                    Text("List is empty")
                        
                } else {
                    Text("End of list")
                }
            }
            .font(.footnote)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
            .fullWidth()
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
        }
        .animation(.default, value: users)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(title)
        .buttonStyle(.plain)
    }
    
    var userListLoadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
                .tint(.scOrange)
            Text("Loading users...")
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
