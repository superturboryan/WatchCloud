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
    
    @State var isWatchAppInstalled = false
    @State var showSplashScreen = true
        
    @Namespace var header
    
    var body: some View {
        NavigationView {
            ZStack {
                if showSplashScreen {
                    splashScreen.zIndex(1)
                } else {
                    rootView.zIndex(0)
                }
            }
            .animation(.default, value: showSplashScreen)
            .fullWidthAndHeight()
            .background(Color.black)
        }
        .task {
            authStore.logout()
        }
        .onReceive(WCPhoneSessionHandler.shared.isWatchAppInstalled.receive(on: DispatchQueue.main)) {
            isWatchAppInstalled = $0
        }
    }
    
    private var splashScreen: some View {
        headerView
            .task {
                try? await Task.sleep(for: .seconds(0.75))
                showSplashScreen = false
            }
    }
    
    private var rootView: some View {
        VStack {
            headerView
            Spacer()
            instructionsView
            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button { } label: {
                    Image(systemName: "questionmark.circle")
                        .fontWeight(.bold)
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack {
            appIcon
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            HStack {
                Text("WatchCloud")
                    .font(.system(.title, weight: .bold))
                    .foregroundStyle(.white)
                Text("Login")
                    .font(.system(.title, weight: .bold))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .matchedGeometryEffect(id: "header", in: header)
    }
    
    @ViewBuilder
    private var instructionsView: some View {
        let disabledOpacity = 0.5
        
        VStack(spacing: 60) {
            
            // 1
            VStack(spacing: 16) {
                Label("Install WatchCloud app onto Apple Watch", systemImage: "1.circle")
                    .opacity(isWatchAppInstalled ? disabledOpacity : 1)
                HStack {
                    Image(systemName: isWatchAppInstalled ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundStyle(isWatchAppInstalled ? .green : .yellow)
                        .symbolReplaceEffect()
                    Text("Watch App\(isWatchAppInstalled ? "" : " Not") Installed")
                }
                .padding()
                .background(.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .animation(.default, value: isWatchAppInstalled)
            
            // 2
            VStack(spacing: 16) {
                Label("Connect to SoundCloud account", systemImage: "2.circle")
                    .opacity(isWatchAppInstalled && !authStore.isLoggedIn ? 1 : disabledOpacity)
                
                Group {
                    if authStore.isLoggedIn {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Account Connected")
                        }
                        .padding()
                        .background(.white.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        LoginButton {
                            performLoginAndSendTokens()
                        }
                        .opacity(isWatchAppInstalled ? 1 : disabledOpacity)
                        .disabled(!isWatchAppInstalled)
                    }
                }
                .animation(.default, value: isWatchAppInstalled)
                .animation(.default, value: authStore.isLoggedIn)
            }
            
            // 3
            VStack(spacing: 16) {
                Label("Open app on Apple Watch", systemImage: "3.circle")
                appIcon
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            .opacity(authStore.isLoggedIn ? 1 : disabledOpacity)
            .animation(.default, value: authStore.isLoggedIn)
        }
        .font(.headline)
        .foregroundStyle(.white)
    }
    
    private var appIcon: some View {
        Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
            .resizable()
            .scaledToFill()
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
    RootView().environmentObject(AuthStore(testSC))
}
