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
    @State var showTip = false
    
    @available(watchOS 10, *)
    @Parameter static var hasTriedToLoginAndCancelled: Bool = false

    var body: some View {
        VStack {
            captchaNotAppearingTip
            loginButton
        }
        .fullWidthAndHeight()
        .background(.black)
        .overlay(alignment: .bottom) {
            if !showTip {
                PoweredBySCView()
                    .padding(.bottom, 8)
                    .animation(.default, value: showTip)
            }
        }.alert(
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
    private var captchaNotAppearingTip: some View {
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
