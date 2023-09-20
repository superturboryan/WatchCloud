//
//  CurrentUserView.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-08-29.
//

import NukeUI
import SoundCloud
import SwiftUI

struct CurrentUserView: View {
    
    @EnvironmentObject var sc: SoundCloud
    @Environment(\.dismiss) var dismiss
    
    @State var showLogoutAlert = false
    
    var body: some View {
        VStack(spacing: 10) {
            userView
            Button("Logout") { showLogoutAlert = true }
                .foregroundColor(.red)
                .fontWeight(.medium)
        }
        .padding(.bottom, 6)
        .padding(.top, -20)
        .edgesIgnoringSafeArea([.bottom])
        .alert("Are you sure you want to logout?", isPresented: $showLogoutAlert) {
            Button("Logout", role: .destructive) {
                Haptics.click()
                sc.logout()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    var userView: some View {
        VStack(spacing: 12) {
            userAvatarImage
                .frame(width: 120)
                .clipShape(Circle())
                .overlay(alignment: .bottom) {
                    Text(sc.myUser!.subscription)
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 2)
                        .background(LinearGradient.scOrange())
                        .cornerRadius(2)
                        .offset(y: 6)
            }
            ShareLink(item: URL(string: sc.myUser!.permalinkUrl)!, label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                    Text(sc.myUser!.username)
                        .lineLimit(2)
                }
                .font(.headline)
            })
            .buttonStyle(.plain)
        }
        .padding(4)
    }
    
    var userAvatarImage: some View {
        LazyImage(url: URL(string: sc.myUser!.avatarUrl)) { state in
            if let image = state.image {
                image.resizable().scaledToFit()
            } else if state.error != nil {
                Image(systemName: "person").resizable().scaledToFit()
            } else {
                ProgressView()
            }
        }
    }
}

struct CurrentUserView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CurrentUserView().environmentObject({ () -> SoundCloud in
                testSC.myUser = testUser
                return testSC
            }())
        }
    }
}
