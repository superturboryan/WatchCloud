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
    @State var showAboutView = false
    @State var showSplashScreen = true
    
    private let disabledOpacity = 0.4
    
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
            .sheet(isPresented: $showAboutView) {
                AboutView()
            }
        }
        .task {
            authStore.logout()
        }
        .onReceive(WCPhoneSessionHandler.shared.isWatchAppInstalled) {
            isWatchAppInstalled = $0
        }
    }
    
    private var splashScreen: some View {
        headerView
            .task {
                // Hide after delay
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
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    showAboutView = true
                } label: {
                    Image(systemName: "info.circle")
                        .fontWeight(.bold)
                }
                .tint(.scOrangeLight)
            }
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        let iconSize = Device.screenSize.width / 4
        VStack {
            appIcon
                .frame(width: iconSize, height: iconSize)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            HStack {
                Text(String(localized: "WatchCloud", comment: "App Name/Title"))
                    .font(.system(.title, weight: .bold))
                Text(String(localized: "Login", comment: "App Name/Title"))
                    .font(.system(.title, weight: .bold))
                    .foregroundStyle(.primary.opacity(0.6))
            }
        }
        .matchedGeometryEffect(id: "header", in: header)
    }
    
    @ViewBuilder
    private var instructionsView: some View {
        VStack(spacing: 60) {
            installWatchOSApp // 1
            connectToSoundCloud // 2
            openWatchOSApp // 3
        }
        .font(.headline)
        .fontWeight(.bold)
    }
    
    private var installWatchOSApp: some View {
        VStack(spacing: 16) {
            Label("Install WatchCloud app on Apple Watch", systemImage: "1.circle")
                .opacity(isWatchAppInstalled ? disabledOpacity : 1)
            HStack {
                Image(systemName: isWatchAppInstalled ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(isWatchAppInstalled ? .green : .scOrangeLight)
                    .symbolReplaceEffect()
                if isWatchAppInstalled {
                    Text("Watch App Installed")
                } else {
                    Text("Watch App Not Installed")
                }
            }
            .padding()
            .background(.primary.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .animation(.default, value: isWatchAppInstalled)
    }
    
    private var connectToSoundCloud: some View {
        VStack(spacing: 16) {
            Label("Connect to SoundCloud", systemImage: "2.circle")
                .opacity(isWatchAppInstalled && !authStore.isLoggedIn ? 1 : disabledOpacity)
            
            ZStack {
                if authStore.isLoggedIn {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Account Connected")
                    }
                    .padding()
                    .background(.primary.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .zIndex(1)
                } else {
                    LoginButton {
                        performLoginAndSendTokens()
                    }
                    .opacity(isWatchAppInstalled ? 1 : disabledOpacity)
                    .disabled(!isWatchAppInstalled)
                    .zIndex(0)
                }
            }
            .animation(.default, value: authStore.isLoggedIn)
        }
    }
    
    private var openWatchOSApp: some View {
        VStack(spacing: 16) {
            Label("Open app on Apple Watch", systemImage: "3.circle")
            appIcon
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        }
        .opacity(authStore.isLoggedIn ? 1 : disabledOpacity)
        .animation(.default, value: authStore.isLoggedIn)
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
}

#Preview {
    RootView().environmentObject(AuthStore(testSC))
}
