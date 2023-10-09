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

    var body: some View {
        VStack {
            if #available(watchOS 10, *) {
                TipView(CaptchaNotAppearingTip(), arrowEdge: .bottom).onAppear {
                    showingTip = true
                }.onDisappear {
                    showingTip = false
                }
                .animation(.default, value: showingTip)
            }
            
            Button {
                Task {
                    do {
                        try await sc.login()
                        AnalyticsManager.shared.log(.loginSuccess)
                    } catch(SoundCloud.Error.cancelledLogin) {
                        AnalyticsManager.shared.log(.loginCancelled)
                    } catch {
                        showErrorAlert = true
                        AnalyticsManager.shared.log(.loginFailure)
                    }
                }
            } label: {
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
}

#Preview {
    LoginView().environmentObject(testSC)
}
