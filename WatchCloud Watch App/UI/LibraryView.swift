//
//  LibraryView.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-09-04.
//

import SoundCloud
import SwiftUI

struct LibraryView: View {

    @EnvironmentObject var audioStore: AudioStore
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var userStore: UserStore

    private let topCell = "top"
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { sv in
                let scrollToTop = { sv.scrollTo(topCell, anchor: .top) }
                libraryView
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(String(localized:"Library"))
                    .onChange(of: authStore.isLoggedIn) { if $0 { scrollToTop() } }
            }
        }
    }
    
    private var libraryView: some View {
        List {
            if let nowPlayingBinding = Binding($audioStore.loadedPlaylists[PlaylistType.nowPlaying.rawValue]),
               !(nowPlayingBinding.wrappedValue.tracks?.isEmpty ?? true) {
                nowPlayingCell(nowPlayingBinding).id(topCell)
                searchCell
                downloadsCell
            } else {
                searchCell.id(topCell)
                downloadsCell
            }

            if let likedTracksPlaylist = Binding($audioStore.loadedPlaylists[PlaylistType.likes.rawValue]) {
                systemPlaylistCell(likedTracksPlaylist)
            }
            
            if let recentlyPostedPlaylist = Binding($audioStore.loadedPlaylists[PlaylistType.recentlyPosted.rawValue]) {
                systemPlaylistCell(recentlyPostedPlaylist)
            }

            followingCell

            if !audioStore.myPlaylistIds.isEmpty {
                Section(header: sectionHeaderView(String(localized:"My Playlists"))) {
                    ForEach($audioStore.loadedPlaylists.values
                        .filter { audioStore.myPlaylistIds.contains($0.wrappedValue.id) }
                        .sorted(by: { $0.wrappedValue.title < $1.wrappedValue.title })
                    ) {
                        userPlaylistCell($0)
                    }
                }
            }
            
            if !audioStore.myLikedPlaylistIds.isEmpty {
                Section(header: sectionHeaderView(String(localized: "Liked Playlists"))) {
                    ForEach($audioStore.loadedPlaylists.values
                        .filter { audioStore.myLikedPlaylistIds.contains($0.wrappedValue.id) }
                        .sorted(by: { $0.wrappedValue.title < $1.wrappedValue.title })
                    ) {
                        userPlaylistCell($0)
                    }
                }
            }

            Section(header: sectionHeaderView(String(localized: "My Account"))) {
                currentUserCell
                settingsCell
            }

            PoweredBySCView()
                .padding(.top, 14)
                .fullWidth()
                .listRowBackground(Color.clear)
        }
    }
    
    func nowPlayingCell(_ playlist: Binding<Playlist>) -> some View {
        navigationCell(
            id: PlaylistType.nowPlaying.rawValue,
            title: PlaylistType.nowPlaying.title,
            subtitle: audioStore.loadedTrack?.title ?? "...",
            bgColor: .orange.opacity(0.2)) {
                PlaylistView(
                    playlist: playlist,
                    showSummary: false,
                    scrollToNowPlaying: true,
                    updateNowPlayingPlaylist: false
                )
            }
    }
    
    @ViewBuilder
    var downloadsCell: some View {
        if Config.isDownloadingEnabled(for: userStore.myUser?.id) {
            navigationCell(
                id: PlaylistType.downloads.rawValue,
                title: PlaylistType.downloads.title) {
                    DownloadsView()
                }
        }
    }
    
    func systemPlaylistCell(_ playlist: Binding<Playlist>) -> some View {
        navigationCell(id: playlist.wrappedValue.id, title: playlist.wrappedValue.title) {
            PlaylistView(
                playlist: playlist,
                onFirstLoad: {
                    AnalyticsManager.shared.log(.tappedSystemPlaylist)
                    try await audioStore.loadTracksForPlaylist(with: playlist.id)
                }
            )
        }
    }
    
    func userPlaylistCell(_ playlist: Binding<Playlist>) -> some View {
        NavigationLink {
            PlaylistView(
                playlist: playlist,
                onFirstLoad: {
                    AnalyticsManager.shared.log(.tappedUserPlaylist)
                    try await audioStore.loadTracksForPlaylist(with: playlist.id)
                }
            )
        } label: {
            PlaylistCellView(playlist: playlist)
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
    
    var currentUserCell: some View {
        navigationCell(id: -1, title: userStore.myUser?.username ?? "User") {
            CurrentUserView()
        }
    }
    
    var settingsCell: some View {
        navigationCell(id: -2, title: String(localized: "Settings")) {
            SettingsView()
        }
    }
    
    @ViewBuilder
    var followingCell: some View {
        let title = String(localized: "Following")

        navigationCell(id: -3, title: title) {
            UserListView(
                users: $userStore.usersImFollowing.items,
                canLoadMore: Binding(get: { $userStore.usersImFollowing.wrappedValue.hasNextPage }, set: { _ in }),
                title: title,
                sortedAlphabetically: true,
                reachedBottomOfList: {
                Task {
                    try? await userStore.loadUsersImFollowing()
                }
            })
        }
    }

    var searchCell: some View {
        navigationCell(id: -4, title: String(localized: "Search", comment: "Verb")) {
            SearchView()
        }
    }
    
    func navigationCell(
        id: Int,
        title: String,
        subtitle: String? = nil,
        bgColor: Color = .cellBG,
        destination: () -> some View
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 8) {
                imageForCell(id)
                VStack {
                    Text(verbatim: title)
                        .font(subtitle == nil ? .body : .headline)
                        .fullWidth(.leading)
                        .minimumScaleFactor(0.8)
                    if let subtitle {
                        Text(verbatim: subtitle)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .fullWidth(.leading)
                    }
                }
            }
            .lineLimit(1)
            .fontDesign(.rounded)
            .padding(14)
            .background(bgColor)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
    
    func imageForCell(_ id: Int) -> some View {
        var imageName: String = "square.slash"
        var colour: Color?
        var gradient: LinearGradient?
        
        switch id {
        case PlaylistType.likes.rawValue:
            imageName = "heart.fill"
            colour = .pink
        case PlaylistType.recentlyPosted.rawValue:
            imageName = "dot.radiowaves.up.forward"
            colour = .mint
        case PlaylistType.nowPlaying.rawValue:
            imageName = "speaker.wave.2.fill"
            gradient = LinearGradient.scOrange(.horizontal)
        case PlaylistType.downloads.rawValue:
            imageName = "arrow.down.circle.fill"
            colour = .green
            
        case -1: // Current User View
            imageName = "person.circle.fill"
            gradient = LinearGradient.scOrange(.vertical)
        case -2: // Settings
            imageName = "gearshape.fill"
            colour = .gray
        case -3: // Following
            imageName = "person.2.fill"
            gradient = .scOrange(.horizontal, reversed: true)
        case -4: // Search
            imageName = "magnifyingglass.circle.fill"
            gradient = LinearGradient.scOrange(.vertical)
        
        default:
            imageName = "music.note.list"
            colour = Color.scOrange
        }
        
        var image: any View = Image(systemName: imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .fontWeight(.medium)
            .frame(width: 20, height: 20)
        
        if let gradient { image = image.foregroundStyle(gradient) }
        else if let colour { image = image.foregroundColor(colour) }
        
        return AnyView(image)
    }
}

#Preview {
    LibraryView()
        .environmentObject(AudioStore(testSC))
        .environmentObject(AuthStore(testSC))
        .environmentObject(UserStore(testSC))
}
