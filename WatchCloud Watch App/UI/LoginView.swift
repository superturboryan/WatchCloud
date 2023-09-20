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
        VStack(spacing: 10) {
            Spacer()
            
            Button {
                Task {
                    do {
                        try await sc.login()
                    } catch {
                        showErrorAlert = true
                    }
                }
            } label: {
                Image.connectSC
            }
            Spacer()
            Image.poweredBySoundCloud
        }
        .alert("Failed to connect to SoundCloud, \nplease try again", isPresented: $showErrorAlert) {
            Button("Ok") {}
        }
        .toolbar(.hidden, for: .navigationBar)
        .buttonStyle(.plain)
        .padding(.vertical, 10)
        .fullWidth()
        .ignoresSafeArea()
        .navigationTitle("")
        .interactiveDismissDisabled() // Disables dismiss with watch crown
    }
}

struct LoginView_Previews: PreviewProvider {
    
    static var previews: some View {
        LoginView().environmentObject(testSC)
    }
}
