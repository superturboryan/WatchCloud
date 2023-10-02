//
//  CurrentUserView.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-08-29.
//

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
            Button(String(localized: "Cancel", comment: "Verb"), role: .cancel) {}
        }
        .toolbarBackground(.clear, for: .navigationBar)
    }
    
    var userView: some View {
        GeometryReader { geo in
            VStack(spacing: 12) {
                CachedImageView(url: sc.myUser!.avatarUrl)
                    .frame(width: geo.size.width * 0.6)
                    .clipShape(Circle())
                    
                ShareLink(item: URL(string: sc.myUser!.permalinkUrl)!, label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                        Text(verbatim: sc.myUser!.username)
                            .lineLimit(2)
                    }
                    .font(.headline)
                })
                .buttonStyle(.plain)
            }
            .padding(4)
            .fullWidthAndHeight()
        }
    }
}

#Preview {
    NavigationStack {
        CurrentUserView().environmentObject({ () -> SoundCloud in
            testSC.myUser = testUser
            return testSC
        }())
    }
}
