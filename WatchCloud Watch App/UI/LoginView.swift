//
//  LoginView.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-08-14.
//

import SoundCloud
import SwiftUI
import TipKit

struct LoginView: View {

    @EnvironmentObject var authStore: AuthStore
    
    @State var showErrorAlert = false
    @State var showLoginButton = false
    @State var showTip = false
    
    @available(watchOS 10, *)
    @Parameter static var hasTriedToLoginAndCancelled: Bool = false

    var body: some View {
        VStack(spacing: 30) {
            if !showLoginButton {
                connectOnPhonePrompt
                showLoginButtonButton
            } else {
                loginButton
            }
        }
        .fontDesign(.rounded)
        .animation(.default, value: showLoginButton)
        .fullWidthAndHeight()
        .background(.black)
        .alert(
            "Failed to connect to SoundCloud, \nplease try again",
            isPresented: $showErrorAlert
        ) {
            Button("Ok") {}
        }
        .toolbar(.hidden, for: .navigationBar)
        .buttonStyle(.plain)
        .ignoresSafeArea()
        .interactiveDismissDisabled()
    }
    
    private var connectOnPhonePrompt: some View {
        Text("Connect to SoundCloud using the WatchCloud iOS app on your phone (recommended)")
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding(.top)
    }
    
    private var showLoginButtonButton: some View {
        Button {
            showLoginButton = true
        } label: {
            Text("or connect here")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(LinearGradient.scOrange(.horizontal, reversed: true))
        }
    }
    
    private var loginButton: some View {
        LoginButton {
            Task {
                do {
                    try await authStore.login()
                    AnalyticsManager.shared.log(.loginSuccess)
                } catch(AuthStore.Error.cancelledLogin) {
                    AnalyticsManager.shared.log(.loginCancelled)
                    if #available(watchOS 10, *) {
                        LoginView.hasTriedToLoginAndCancelled = true
                        Haptics.notification()
                    }
                } catch {
                    showErrorAlert = true
                    AnalyticsManager.shared.log(.loginFailure)
                }
            }
        }
    }

    @ViewBuilder
    private var captchaNotAppearingTip: some View { // ‼️ Not currently shown
        if #available(watchOS 10, *) {
            TipView(CaptchaNotAppearingTip(), arrowEdge: .bottom)
            .onVisibilityChange { showTip = $0 }
            .animation(.default, value: showTip)
        } else {
            EmptyView()
        }
    }
}

#Preview {
    LoginView().environmentObject(AuthStore(testSC))
}
