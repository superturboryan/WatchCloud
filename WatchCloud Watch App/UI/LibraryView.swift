//
//  LibraryView.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-09-04.
//

import SoundCloud
import SwiftUI

struct LibraryView: View {

    @EnvironmentObject var sc: SoundCloud

    @Binding var rootSelectedTab: RootTab
    
    let 👆 = "👆"
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { sv in
                let scrollToTop = { sv.scrollTo(👆, anchor: .top) }
                ScrollView {
                    VStack {
                        if let nowPlayingBinding = Binding($sc.loadedPlaylists[PlaylistType.nowPlaying.rawValue]),
                           !(nowPlayingBinding.wrappedValue.tracks?.isEmpty ?? true) {
                            nowPlayingCell(nowPlayingBinding).id(👆)
                            if Config.isDownloadingEnabled(for: sc.myUser?.id) {
                                downloadsCell
                            }
                        } else {
                            if Config.isDownloadingEnabled(for: sc.myUser?.id) {
                                downloadsCell.id(👆)
                            }
                        }

                        playlistCell(Binding($sc.loadedPlaylists[PlaylistType.likes.rawValue])!)

                        playlistCell(Binding($sc.loadedPlaylists[PlaylistType.recentlyPosted.rawValue])!)

                        followingCell

                        if !sc.myPlaylistIds.isEmpty {
                            Section(header: sectionHeaderView(String(localized:"My Playlists"))) {
                                ForEach($sc.loadedPlaylists.values
                                    .filter { sc.myPlaylistIds.contains($0.wrappedValue.id) }
                                    .sorted(by: { $0.wrappedValue.title < $1.wrappedValue.title })
                                ) {
                                    playlistCell($0)
                                }
                            }
                        }
                        
                        if !sc.myLikedPlaylistIds.isEmpty {
                            Section(header: sectionHeaderView(String(localized: "Liked Playlists"))) {
                                ForEach($sc.loadedPlaylists.values
                                    .filter { sc.myLikedPlaylistIds.contains($0.wrappedValue.id) }
                                    .sorted(by: { $0.wrappedValue.title < $1.wrappedValue.title })
                                ) {
                                    playlistCell($0)
                                }
                            }
                        }

                        Section(header: sectionHeaderView(String(localized: "My Account"))) {
                            currentUserCell
//                            settingsCell
                        }

                        PoweredBySCView()
                            .padding(.top, 20)
                    }
                    .padding(.horizontal, 4)
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(String(localized:"Library"))
                .onChange(of: sc.isLoggedIn) { if $0 { scrollToTop() } } // Don't need to scroll if not logged in? 🤔
            }
        }
    }
    
    // Special playlist cells //////////////////////////////////////////////////////////////////////
    func nowPlayingCell(_ playlist: Binding<Playlist>) -> some View {
        navigationCell(
            id: PlaylistType.nowPlaying.rawValue,
            title: PlaylistType.nowPlaying.title,
            subtitle: sc.loadedTrack?.title ?? "...",
            bgColor: .orange) {
                PlaylistView(
                    playlist: playlist,
                    downloadedTracks: sc.downloadedTracks,
                    didSelectTrack: { _ in
                        switchToPlayerViewTabAfterDelay()
                    },
                    showHeader: false,
                    scrollToNowPlaying: true,
                    updateNowPlayingPlaylist: false
                )
            }
    }
    
    var downloadsCell: some View {
        navigationCell(
            id: PlaylistType.downloads.rawValue,
            title: PlaylistType.downloads.title) {
                DownloadsView(didSelectTrack: { _ in
                    switchToPlayerViewTabAfterDelay()
                })
            }
    }
    // /////////////////////////////////////////////////////////////////////////////////////////////
    
    func playlistCell(_ playlist: Binding<Playlist>) -> some View {
        navigationCell(id: playlist.wrappedValue.id, title: playlist.wrappedValue.title) {
            PlaylistView(
                playlist: playlist,
                downloadedTracks: sc.downloadedTracks,
                onFirstLoad: {
                    try await sc.loadTracksForPlaylist(with: playlist.id)
                },
                didSelectTrack: { _ in
                    switchToPlayerViewTabAfterDelay()
                }
            )
        }
    }
    
    var currentUserCell: some View {
        navigationCell(id: -1, title: sc.myUser?.username ?? "User") {
            CurrentUserView()
        }
    }
    
    @ViewBuilder
    var settingsCell: some View {
        let settingsTitle = "Settings"
        navigationCell(id: -2, title: "Settings") {
            SettingsView()
        }
    }
    
    @ViewBuilder
    var followingCell: some View {
        let title = String(localized: "Following")
        if let usersImFollowingBinding = Binding($sc.usersImFollowing) {
            navigationCell(id: -3, title: title) {
                UserListView(
                    users: usersImFollowingBinding.items,
                    canLoadMore: Binding(get: { usersImFollowingBinding.wrappedValue.hasNextPage }, set: { _ in }),
                    title: title) {
                    Task {
                        try? await sc.loadUsersImFollowing()
                    }
                }
            }
        }
    }

    func switchToPlayerViewTabAfterDelay() {
        Task {
            try await Task.sleep(for: .seconds(0.4))
            withAnimation { rootSelectedTab = RootTab.player }
        }
    }
    
    func navigationCell(
        id: Int,
        title: String,
        subtitle: String? = nil,
        bgColor: Color = .secondary,
        destination: () -> some View
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 8) {
                imageForCell(id)
                VStack {
                    Text(verbatim: title)
                        .font(subtitle == nil ? .body : .headline) // Make prominent if subtitle exists
                        .fullWidth(.leading)
                        .minimumScaleFactor(0.9)
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
            .padding(10)
            .background(bgColor.opacity(0.2))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
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
            colour = .indigo
        case PlaylistType.nowPlaying.rawValue:
            imageName = "speaker.wave.2.fill"
            gradient = LinearGradient.scOrange(.horizontal)
        case PlaylistType.downloads.rawValue:
            imageName = "arrow.down.circle.fill"
            colour = .green
            
        case -1: // Current User View
            imageName = "figure.dance"
            gradient = LinearGradient.scOrange(.vertical)
        case -2: // Settings
            imageName = "gearshape.fill"
            colour = .gray
        case -3:
            imageName = "person.2.wave.2.fill"
            colour = .scOrange
        
        default:
            imageName = "music.note.list"
            colour = Color.scOrange
        }
        
        var image: any View =
        Image(systemName: imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .fontWeight(.medium)
            .frame(width: 20, height: 20)
        
        if let gradient { image = image.foregroundStyle(gradient) }
        else if let colour { image = image.foregroundColor(colour) }
        
        return AnyView(image)
    }
    
    var poweredBySCLogo: some View {
        Image.poweredBySoundCloud
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 20)
            .padding(.top)
    }
}

#Preview {
    LibraryView(rootSelectedTab: Binding(get: { RootTab.library }, set: { _ in }))
        .environmentObject({() -> SoundCloud in
            let sc = SoundCloud(testSCConfig)
            sc.loadedPlaylists = testDefaultLoadedPlaylists
            let testPlaylist = testPlaylist(empty: true)
            let testPlaylistId = testPlaylist.id
            sc.myPlaylistIds = [testPlaylistId]
            sc.myLikedPlaylistIds = [testPlaylistId]
            sc.loadedPlaylists[testPlaylistId] = testPlaylist
            return sc
        }())
}
