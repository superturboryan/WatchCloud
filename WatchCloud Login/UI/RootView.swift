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
            .fullWidthAndHeight()
            .background(Color.black)
            .animation(.default, value: showSplashScreen)
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
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack {
            appIcon
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text("WatchCloud Login")
                .font(.system(.title, weight: .bold))
                .foregroundStyle(.white)
        }
        .matchedGeometryEffect(id: "header", in: header)
    }
    
    private var instructionsView: some View {
        VStack(spacing: 60) {
            
            VStack(spacing: 16) {
                Text("1) Install WatchCloud app onto Apple Watch")
                    .font(.headline)
                    .opacity(isWatchAppInstalled ? 0.7 : 1)
                HStack {
                    Image(systemName: isWatchAppInstalled ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundStyle(isWatchAppInstalled ? .green : .yellow)
                    Text("Watch App\(isWatchAppInstalled ? "" : " Not") Installed")
                        .fontWeight(.semibold)
                }
                .padding()
                .background(.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(spacing: 16) {
                
                Text("2) Connect to SoundCloud account")
                    .font(.headline)
                    .opacity(isWatchAppInstalled && !authStore.isLoggedIn ? 1 : 0.7)
                
                Group {
                    if authStore.isLoggedIn {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Account Connected")
                        }
                        .fontWeight(.semibold)
                        .padding()
                        .background(.white.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        LoginButton {
                            performLoginAndSendTokens()
                        }
                        .opacity(isWatchAppInstalled ? 1 : 0.5)
                        .disabled(!isWatchAppInstalled)
                    }
                }
            }
            
            VStack(spacing: 16) {
                Text("3) Open app on Apple Watch")
                    .font(.headline)
                    .opacity(authStore.isLoggedIn ? 1 : 0.7)
                
                openWatchAppPrompt
                    .opacity(authStore.isLoggedIn ? 1 : 0)
            }
        }
        .animation(.default, value: authStore.isLoggedIn && isWatchAppInstalled)
        .foregroundStyle(.white)
    }
    
    private var openWatchAppPrompt: some View {
        appIcon
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .zIndex(1)
    }
    
    private var appIcon: some View {
        Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
            .resizable()
            .scaledToFill()
    }
    
    private var infoButton: some View {
        Button {
            print("Tapped info")
        } label: {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                Text("Help").fontWeight(.semibold)
            }
            .foregroundStyle(.white)
        }
        .buttonStyle(.borderedProminent)
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
