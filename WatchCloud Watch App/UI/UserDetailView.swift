//
//  UserDetailView.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-03.
//

import SoundCloud
import SwiftUI

struct UserDetailView: View {
    
    @EnvironmentObject var sc: SoundCloud
    @Binding var user: User
    
    var isFollowed: Bool {
        (sc.usersImFollowing?.items ?? []).contains(user)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                summary
            }
            .padding(.top, -20)
            .padding(.horizontal)
            .fontDesign(.rounded)
        }
        .toolbar {
            followButton
        }
    }
    
    private var summary: some View {
        GeometryReader { geo in
            VStack(spacing: 10) {
                CachedImageView(url: user.largerAvatarUrl)
                    .frame(width: geo.size.width * 0.6, height: geo.size.width * 0.6)
                    .clipShape(Circle())
                    .overlay(alignment: .bottom) {
                        subscriptionLabel
                    }

                artistInfoLabels
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var artistInfoLabels: some View {
        VStack {
            Text(user.username)
                .font(.headline)
            HStack(spacing: 6) {
                HStack(spacing: 2) {
                    Image(systemName: "mappin").foregroundStyle(.blue)
                    Text(user.city ?? "?")
                }
                Spacer(minLength: 0)
                HStack(spacing: 2) {
                    Image(systemName: "person.wave.2.fill").foregroundStyle(Color.scOrange)
                    Text(user.followersCount.formattedIfOver1000)
                }
                Spacer(minLength: 0)
                HStack(spacing: 2) {
                    Image(systemName: "music.note").foregroundStyle(Color.scOrange)
                    Text(user.trackCount.formattedIfOver1000)
                }
            }
            .font(.footnote)
            .minimumScaleFactor(0.8)
        }
    }
    
    private var followButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                print("Follow button tapped")
            } label: {
                Image(systemName: isFollowed ? "person.fill.checkmark" : "person.fill.badge.plus")
                    .foregroundStyle(Color.scOrange)
            }
        }
    }
    
    @ViewBuilder
    private var subscriptionLabel: some View {
        if user.subscription.lowercased() != "free" {
            Text(user.subscription)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 3)
                .background { LinearGradient.scOrange(.vertical) }
                .roundedCorner(4, corners: .allCorners)
                .offset(y: 3)
        }
    }
    
    private func playlistSection(_ title: String, _ tracks: [Track]) -> some View {
        Text("")
    }
}

#Preview {
    NavigationStack {
        UserDetailView(user: .constant(testUser()))
            .environmentObject(testSC)
    }
}

/**
 Avatar
 Username
 Follower count
 Top tracks (by playcount)
 Latest tracks (by date posted)
 Liked tracks
 */
