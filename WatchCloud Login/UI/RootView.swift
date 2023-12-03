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
    
    private var headerView: some View {
        VStack {
            appIcon
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            HStack {
                Text("WatchCloud")
                    .font(.system(.title, weight: .bold))
                Text("Login")
                    .font(.system(.title, weight: .bold))
                    .foregroundStyle(.primary.opacity(0.6))
            }
        }
        .matchedGeometryEffect(id: "header", in: header)
    }
    
    @ViewBuilder
    private var instructionsView: some View {
        let disabledOpacity = 0.4
        
        VStack(spacing: 60) {
            
            // 1
            VStack(spacing: 16) {
                Label("Install WatchCloud app on Apple Watch", systemImage: "1.circle")
                    .opacity(isWatchAppInstalled ? disabledOpacity : 1)
                HStack {
                    Image(systemName: isWatchAppInstalled ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundStyle(isWatchAppInstalled ? .green : .scOrangeLight)
                        .symbolReplaceEffect()
                    Text("Watch App\(isWatchAppInstalled ? "" : " Not") Installed")
                }
                .padding()
                .background(.primary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .animation(.default, value: isWatchAppInstalled)
            
            // 2
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
        .fontWeight(.bold)
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
