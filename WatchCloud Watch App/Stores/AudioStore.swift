//
//  AudioStore.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-18.
//

import Combine
import Foundation
import SoundCloud

final class AudioStore: ObservableObject {
    
    @Published public var loadedPlaylists: [Int : Playlist] = [:]
    @Published public private(set) var loadedTrackNowPlayingQueueIndex: Int = -1
    
    @Published public var loadedTrack: Track? {
        didSet {
            loadedTrackNowPlayingQueueIndex = loadedPlaylists[PlaylistType.nowPlaying.rawValue]?
                .tracks?
                .firstIndex(where: { $0 == loadedTrack }) ?? -1
        }
    }
    
    @Published public var downloadsInProgress: [Track : Progress] = [:]
    @Published public var downloadedTracks: [Track] = [] { // Tracks with streamURL set to local mp3 url
        didSet {
            loadedPlaylists[PlaylistType.downloads.rawValue]!.tracks = downloadedTracks
        }
    }
    
    // Use id to filter loadedPlaylists dictionary for my + liked playlists
    @Published public var myPlaylistIds: [Int] = []
    @Published public var myLikedPlaylistIds: [Int] = []
    
    public var isLoadedTrackDownloaded: Bool {
        guard let loadedTrack else { return false }
        return downloadedTracks.contains(loadedTrack)
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Dependencies
    private let service: SoundCloudService
    init(_ service: SoundCloudService) {
        self.service = service
        observeDownloads()
    }
    
    private func observeDownloads() {
        service.downloadedTracks.publisher.collect().receive(on: DispatchQueue.main).sink {
            self.downloadedTracks = $0
        }.store(in: &subscriptions)
        
        service.downloadsInProgress.publisher.collect().receive(on: DispatchQueue.main).sink { downloads in
            for download in downloads {
                self.downloadsInProgress[download.key] = download.value
            }
        }.store(in: &subscriptions)
    }
    
    func load() async throws {
        loadDefaultPlaylists()
        try service.loadDownloadedTracks()
        try await loadMyPlaylistsWithoutTracks()
        try await loadMyLikedPlaylistsWithoutTracks()
        try await loadMyLikedTracksPlaylistWithTracks()
        try await loadRecentlyPostedPlaylistWithTracks()
    }
}

extension AudioStore {
    func getTracksForUser(_ id: Int, _ limit: Int = 20) async throws -> Page<Track> {
        try await service.getTracksForUser(id, limit)
    }
    
    func getLikedTracksForUser(_ id: Int, _ limit: Int = 20) async throws -> Page<Track> {
        try await service.getLikedTracksForUser(id, limit)
    }
    
    func getTracksForPlaylist(_ id: Int) async throws -> Page<Track> {
        try await service.getTracksForPlaylist(id)
    }
    
    func searchForTracks(_ query: String) async throws -> Page<Track> {
        try await service.searchTracks(query)
    }
    
    func searchForPlaylists(_ query: String) async throws -> Page<Playlist> {
        try await service.searchPlaylists(query)
    }
    
    func pageOfTracks(_ pageURL: String) async throws -> Page<Track> {
        try await service.pageOfItems(for: pageURL)
    }
    
    func pageOfPlaylists(_ pageURL: String) async throws -> Page<Playlist> {
        try await service.pageOfItems(for: pageURL)
    }
}

// MARK: - Like + Follow
extension AudioStore {
    func likeTrack(_ track: Track) async throws {
        try await service.likeTrack(track)
        // 🚨 Hack for SC API cached responses -> Update loaded playlist manually
        loadedPlaylists[PlaylistType.likes.rawValue]?.tracks?.insert(track, at: 0)
    }
    
    func unlikeTrack(_ track: Track) async throws {
        try await service.unlikeTrack(track)
        // 🚨 Hack for SC API cached responses -> Update loaded playlist manually
        loadedPlaylists[PlaylistType.likes.rawValue]?.tracks?
            .removeAll(where: { $0.id == track.id })
    }
    
    func likePlaylist(_ playlist: Playlist) async throws {
        try await service.likePlaylist(playlist)
        if !myLikedPlaylistIds.contains(playlist.id) {
            myLikedPlaylistIds.insert(playlist.id, at: 0)
        }
    }
    
    func unlikePlaylist(_ playlist: Playlist) async throws {
        try await service.unlikePlaylist(playlist)
        myLikedPlaylistIds.removeAll(where: { $0 == playlist.id })
    }
}

// MARK: - Queue Helpers
extension AudioStore {
    func setNowPlayingQueue(with tracks: [Track]) {
        loadedPlaylists[PlaylistType.nowPlaying.rawValue]?.tracks = tracks
    }
    
    var nowPlayingQueue: [Track]? {
        loadedPlaylists[PlaylistType.nowPlaying.rawValue]?.tracks
    }
    
    var nextTrackInNowPlayingQueue: Track? {
        guard let queue = nowPlayingQueue
        else { return nil }
        
        let isEndOfQueue = loadedTrackNowPlayingQueueIndex == queue.count - 1
        let nextTrackIndex = isEndOfQueue ? 0 : loadedTrackNowPlayingQueueIndex + 1
        return queue[nextTrackIndex]
    }
    
    var previousTrackInNowPlayingQueue: Track? {
        guard let queue = nowPlayingQueue,
              loadedTrackNowPlayingQueueIndex > 0
        else { return nil }
        
        let previousTrackIndex = loadedTrackNowPlayingQueueIndex - 1
        return queue[previousTrackIndex]
    }
}

extension AudioStore {
    func download(_ track: Track) async throws {
        try await service.download(track)
    }
    
    func removeDownload(_ trackToRemove: Track) throws {
        try service.removeDownload(trackToRemove)
    }
    
    func cancelDownloadInProgress(for track: Track) throws {
        try service.cancelDownloadInProgress(for: track)
    }
}

private extension AudioStore {
    func loadDefaultPlaylists() {
        loadedPlaylists.removeAll()
        let myUser = User(id: -1)
        
        loadedPlaylists[PlaylistType.nowPlaying.rawValue] = Playlist(
            id: PlaylistType.nowPlaying.rawValue,
            user: myUser,
            title: PlaylistType.nowPlaying.title,
            tracks: []
        )
        loadedPlaylists[PlaylistType.downloads.rawValue] = Playlist(
            id: PlaylistType.downloads.rawValue,
            user: myUser,
            title: PlaylistType.downloads.title,
            tracks: []
        )
        loadedPlaylists[PlaylistType.likes.rawValue] = Playlist(
            id: PlaylistType.likes.rawValue,
            permalinkUrl: myUser.permalinkUrl + "/likes",
            user: myUser,
            title: PlaylistType.likes.title,
            tracks: []
        )
        loadedPlaylists[PlaylistType.recentlyPosted.rawValue] = Playlist(
            id: PlaylistType.recentlyPosted.rawValue,
            permalinkUrl: myUser.permalinkUrl + "/following",
            user: myUser,
            title: PlaylistType.recentlyPosted.title,
            tracks: []
        )
    }
    
    func loadMyPlaylistsWithoutTracks() async throws {
        let myPlaylists = try await service.getMyPlaylistsWithoutTracks()
        myPlaylistIds = myPlaylists.map(\.id)
        for playlist in myPlaylists {
            loadedPlaylists[playlist.id] = playlist
        }
    }
    
    func loadMyLikedPlaylistsWithoutTracks() async throws {
        let myLikedPlaylists = try await service.getMyLikedPlaylistsWithoutTracks()
        myLikedPlaylistIds = myLikedPlaylists.map(\.id)
        for playlist in myLikedPlaylists {
            loadedPlaylists[playlist.id] = playlist
        }
    }
    
    func loadMyLikedTracksPlaylistWithTracks() async throws {
        let page = try await service.getMyLikedTracks()
        loadedPlaylists[PlaylistType.likes.rawValue]?.tracks = page.items
        loadedPlaylists[PlaylistType.likes.rawValue]?.nextPageUrl = page.nextPage
    }
    
    func loadRecentlyPostedPlaylistWithTracks() async throws {
        loadedPlaylists[PlaylistType.recentlyPosted.rawValue]?.tracks =
        try await service.getMyFollowingsRecentlyPosted()
    }
}
