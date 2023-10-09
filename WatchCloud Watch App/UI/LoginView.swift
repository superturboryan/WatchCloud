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

    @EnvironmentObject var sc: SoundCloud
    @State var showErrorAlert = false
    @State var showingTip = false
    
    @available(watchOS 10, *)
    @Parameter static var hasTriedToLoginAndCancelled: Bool = false

    var body: some View {
        VStack {
            captchaNotAppearingTip
            loginButton
        }
        .fullWidthAndHeight()
        .overlay(alignment: .bottom) {
            if !showingTip {
                PoweredBySCView()
                    .padding(.bottom, 8)
                    .animation(.default, value: showingTip)
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
        .navigationTitle(String.empty)
        .interactiveDismissDisabled()
    }
    
    private var loginButton: some View {
        Button { tappedLogin() } label: {
            Label(String(localized: "Connect", comment: "Verb"), systemImage: "cloud.fill")
                .lineLimit(1)
                .fontWeight(.semibold)
                .minimumScaleFactor(0.8)
        }
        .font(.title3)
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(.white.opacity(0.12))
        .overlay {
            Capsule()
                .strokeBorder(style: StrokeStyle(lineWidth: 6))
                .foregroundStyle(LinearGradient.scOrange(.horizontal))
        }
        .clipShape(Capsule())
    }
    
    private func tappedLogin() {
        Task {
            do {
                try await sc.login()
                AnalyticsManager.shared.log(.loginSuccess)
            } catch(SoundCloud.Error.cancelledLogin) {
                AnalyticsManager.shared.log(.loginCancelled)
                if #available(watchOS 10, *) {
                    LoginView.hasTriedToLoginAndCancelled = true
                }
            } catch {
                showErrorAlert = true
                AnalyticsManager.shared.log(.loginFailure)
            }
        }
    }
    
    @ViewBuilder
    private var captchaNotAppearingTip: some View {
        if #available(watchOS 10, *) {
            TipView(CaptchaNotAppearingTip(), arrowEdge: .bottom).onVisibilityChange {
                showingTip = $0
            }
            .animation(.default, value: showingTip)
        } else {
            EmptyView()
        }
    }
}

#Preview {
    LoginView().environmentObject(testSC)
}
