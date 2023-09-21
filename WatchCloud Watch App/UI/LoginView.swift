//
//  LoginView.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-08-14.
//

import SoundCloud
import SwiftUI

struct LoginView: View {

    @EnvironmentObject var sc: SoundCloud
    @State var showErrorAlert = false

    var body: some View {
        ZStack {
            Button {
                    Task {
                        do {
                            try await sc.login()
                        } catch {
                            showErrorAlert = true
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "cloud.fill")
                        Text("Connect")
                            .fontWeight(.semibold)
                    }
                    .font(.title3)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 18)
                    .background(.white.opacity(0.12))
                    .overlay {
                        Capsule()
                            .strokeBorder(style: StrokeStyle(lineWidth: 6))
                            .foregroundStyle(LinearGradient.scOrange(.horizontal))
                    }
                    .clipShape(Capsule())
                }
        }
        .fullWidthAndHeight()
        .overlay(alignment: .bottom) {
            Image.poweredBySoundCloud
        }.alert(
            "Failed to connect to SoundCloud, \nplease try again",
            isPresented: $showErrorAlert
        ) {
            Button("Ok") {}
        }
        .toolbar(.hidden, for: .navigationBar)
        .buttonStyle(.plain)
        .ignoresSafeArea()
        .navigationTitle("")
        .interactiveDismissDisabled()
    }
}

#Preview {
    LoginView().environmentObject(testSC)
}
