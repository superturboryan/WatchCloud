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
    
    let 👆 = "👆" // TODO: Stringify all emojis?
    
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

                        Section(header: sectionHeaderView("My Playlists")) {
                            ForEach($sc.loadedPlaylists.values.filter { sc.myPlaylistIds.contains($0.wrappedValue.id) }) {
                                playlistCell($0)
                            }
                        }

                        Section(header: sectionHeaderView("Liked Playlists")) {
                            ForEach($sc.loadedPlaylists.values.filter { sc.myLikedPlaylistIds.contains($0.wrappedValue.id) }) {
                                playlistCell($0)
                            }
                        }

                        Section(header: sectionHeaderView("My Account")) {
                            currentUserCell
                            settingsCell
                        }

                        poweredBySCLogo
                    }
                    .padding(.horizontal, 4)
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Library")
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
    
    var settingsCell: some View {
        navigationCell(id: -2, title: "Settings") {
            SettingsView()
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
                    Text(title)
                        .font(subtitle == nil ? .body : .headline) // Make prominent if subtitle exists
                        .fullWidth(.leading)
                        .minimumScaleFactor(0.9)
                    if let subtitle {
                        Text(subtitle)
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
            
            // TODO: Rework playlist enum for other types?
        case -1: // Current User View
            imageName = "figure.dance"
            gradient = LinearGradient.scOrange(.vertical)
        case -2: // Settings
            imageName = "gearshape.fill"
            colour = .gray
        
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

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView(rootSelectedTab: Binding(get: { RootTab.library }, set: { _ in }))
            .environmentObject({() -> SoundCloud in
                let sc = SoundCloud(clientId: "", clientSecret: "", redirectURI: "")
                sc.loadedPlaylists = testDefaultLoadedPlaylists
                let testPlaylist = testPlaylist(empty: true)
                let testPlaylistId = testPlaylist.id
                sc.myPlaylistIds = [testPlaylistId]
                sc.myLikedPlaylistIds = [testPlaylistId]
                sc.loadedPlaylists[testPlaylistId] = testPlaylist
                return sc
            }())
            
    }
}
