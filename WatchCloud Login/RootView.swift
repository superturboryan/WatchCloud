//
//  RootView.swift
//  WatchCloud Login
//
//  Created by Ryan Forsyth on 2023-11-30.
//

import SoundCloud
import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var authStore: AuthStore
        
    var body: some View {
        Group {
            if authStore.isLoggedIn {
                loggedInView
            } else {
                loginView
            }
        }
        .task {
            authStore.logout()
        }
    }
    
    private var loginView: some View {
        VStack {
            Button {
                performLoginAndSendTokens()
            } label: {
                Text("Login")
            }
        }
    }
    
    func performLoginAndSendTokens() {
        Task {
            let tokens = try await authStore.login()
            WCPhoneSessionHandler.shared.send(tokens)
        }
    }
    
    private var loggedInView: some View {
        VStack {
            Text("Login successful")
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AuthStore(testSC))
}
