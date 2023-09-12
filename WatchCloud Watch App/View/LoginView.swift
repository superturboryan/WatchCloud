//
//  LoginView.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-08-14.
//

import SoundCloud
import SwiftUI

struct LoginView: View {

    @EnvironmentObject var sc: SC

    var body: some View {
        VStack {
            Spacer()
            Button { Task { await sc.login() } }
            label: {
                Image.connectSC
            }
            Spacer()
            Image.poweredBySoundCloud
        }
        .buttonStyle(.plain)
        .padding(.vertical, 10)
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
