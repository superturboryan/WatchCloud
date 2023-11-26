//
//  AudioStore.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-18.
//

import Combine
import Foundation
import SoundCloud

final class AudioStore: NSObject, ObservableObject {
    
    @Published var loadedPlaylists: [Int : Playlist] = [:]
    @Published private(set) var loadedTrackPlaylistIndex: Int = -1
    @Published var loadedTrack: Track? {
        didSet {
            loadedTrackPlaylistIndex = nowPlayingQueue?.firstIndex(where: { $0 == loadedTrack }) ?? -1
        }
    }
    
    @Published var downloadsInProgress: [Track : Progress] = [:]
    @Published var downloadedTracks: [Track] = [] { // Tracks with streamURL set to local mp3 url
        didSet {
            loadedPlaylists[PlaylistType.downloads.rawValue]!.tracks = downloadedTracks
        }
    }
    private var downloadTasks: [Track : URLSessionTask] = [:]
    
    // Use id to filter loadedPlaylists dictionary for my + liked playlists
    @Published var myPlaylistIds: [Int] = []
    @Published var myLikedPlaylistIds: [Int] = []
        
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var subscriptions = Set<AnyCancellable>()
    
    private let service: SoundCloudAPI
    private let nowPlayingInfoDAO: any DAO<NowPlayingInfo>
    
    init(
        _ service: SoundCloudAPI,
        _ nowPlayingInfoDAO: any DAO<NowPlayingInfo> = UserDefaultsDAO<NowPlayingInfo>()
    ) {
        self.service = service
        self.nowPlayingInfoDAO = nowPlayingInfoDAO
        super.init()
    }
}

// MARK: - My user 💁
extension AudioStore {
    func load() async throws {
        await loadDefaultPlaylists()
        try await loadDownloadedTracks()
        try await loadMyPlaylistsWithoutTracks()
        try await loadMyLikedPlaylistsWithoutTracks()
        try await loadMyLikedTracksPlaylistWithTracks()
        try await loadRecentlyPostedPlaylistWithTracks()
        
        await loadNowPlayingInfo()
    }
    
    func reset() {
        loadedPlaylists.removeAll()
        loadedTrack = nil
        deleteNowPlayingInfo()
    }
    
    @MainActor
    private func loadDefaultPlaylists() {
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
    
    @MainActor
    private func loadMyPlaylistsWithoutTracks() async throws {
        do {
            let myPlaylists = try await service.getMyPlaylistsWithoutTracks()
            myPlaylistIds = myPlaylists.map(\.id)
            for playlist in myPlaylists {
                loadedPlaylists[playlist.id] = playlist
            }
        } catch {
            throw Error.loadingMyPlaylists
        }
    }
    
    @MainActor
    private func loadMyLikedPlaylistsWithoutTracks() async throws {
        do {
            let myLikedPlaylists = try await service.getMyLikedPlaylistsWithoutTracks()
            myLikedPlaylistIds = myLikedPlaylists.map(\.id)
            for playlist in myLikedPlaylists {
                loadedPlaylists[playlist.id] = playlist
            }
        } catch {
            throw Error.loadingMyLikedPlaylists
        }
    }
    
    @MainActor
    private func loadMyLikedTracksPlaylistWithTracks() async throws {
        let page = try await service.getMyLikedTracks()
        loadedPlaylists[PlaylistType.likes.rawValue]?.updateWith(page)
    }
    
    @MainActor
    private func loadRecentlyPostedPlaylistWithTracks() async throws {
        loadedPlaylists[PlaylistType.recentlyPosted.rawValue]?.tracks =
        try await service.getMyFollowingsRecentlyPosted()
    }
}

// MARK: - Tracks + Playlists 💿
extension AudioStore {
    func getTracksForUser(_ id: Int, _ limit: Int = 20) async throws -> Page<Track> {
        do { return try await service.getTracksForUser(id, limit) }
        catch { throw Error.gettingTracksForUser }
    }
    
    func getLikedTracksForUser(_ id: Int, _ limit: Int = 20) async throws -> Page<Track> {
        do { return try await service.getLikedTracksForUser(id, limit) }
        catch { throw Error.gettingLikedTracksForUser }
    }
    
    func getTracksForPlaylist(_ id: Int) async throws -> Page<Track> {
        do { return try await service.getTracksForPlaylist(id) }
        catch { throw Error.gettingTracksForPlaylist }
    }
    
    func pageOfTracks(_ pageURL: String) async throws -> Page<Track> {
        do { return try await service.pageOfItems(for: pageURL) }
        catch { throw Error.gettingPageOfTracks }
    }
    
    func pageOfPlaylists(_ pageURL: String) async throws -> Page<Playlist> {
        do { return try await service.pageOfItems(for: pageURL) }
        catch { throw Error.gettingPageOfPlaylists }
    }
    
    @MainActor
    func loadTracksForPlaylist(with id: Int) async throws {
        if let userPlaylistType = PlaylistType(rawValue: id) {
            switch userPlaylistType {
            case .likes:
                try await loadMyLikedTracksPlaylistWithTracks()
            case .recentlyPosted:
                try await loadRecentlyPostedPlaylistWithTracks()
            // These playlists are not reloaded here
            case .nowPlaying, .downloads:
                print("⚠️ SC.loadTracksForPlaylist has no effect. Playlist type reloads automatically")
                break
            }
        } else {
            let page = try await getTracksForPlaylist(id)
            loadedPlaylists[id]?.updateWith(page)
        }
    }
    
    func streamInfoForTrack(_ track: Track) async throws -> StreamInfo {
        try await service.getStreamInfoForTrack(with: track.id)
    }
}

// MARK: - Like + Follow 🧡
extension AudioStore {
    
    func isLiked(_ track: Track) -> Bool {
        (loadedPlaylists[PlaylistType.likes.rawValue]?.tracks ?? []).contains(track)
    }
    
    func isLiked(_ playlist: Playlist) -> Bool {
        myLikedPlaylistIds.contains(playlist.id)
    }
    
    func toggleLikedTrack(_ track: Track) async throws {
        do {
            if isLiked(track) { try await unlikeTrack(track) }
            else { try await likeTrack(track) }
        } catch {
            throw Error.togglingLikedTrack
        }
    }
    
    func toggleLikedPlaylist(_ playlist: Playlist) async throws {
        do {
            if isLiked(playlist) { try await unlikePlaylist(playlist) }
            else { try await likePlaylist(playlist) }
        } catch {
            throw Error.togglingLikedPlaylist
        }
    }
    
    @MainActor
    private func likeTrack(_ track: Track) async throws {
        guard !(loadedPlaylists[PlaylistType.likes.rawValue]?.tracks ?? []).contains(track) else {
            return // throw?
        }
        loadedPlaylists[PlaylistType.likes.rawValue]?.tracks?.insert(track, at: 0)
        do {
            try await service.likeTrack(track)
        } catch {
            // Undo local operation if network operation fails
            loadedPlaylists[PlaylistType.likes.rawValue]?.tracks?.removeFirst()
            throw error
        }
    }
    
    @MainActor
    private func unlikeTrack(_ track: Track) async throws {
        guard let index = (loadedPlaylists[PlaylistType.likes.rawValue]?.tracks ?? []).firstIndex(of: track) else {
            return // throw?
        }
        loadedPlaylists[PlaylistType.likes.rawValue]?.tracks?.remove(at: index)
        do {
            try await service.unlikeTrack(track)
        } catch {
            // Undo local operation if network operation fails
            loadedPlaylists[PlaylistType.likes.rawValue]?.tracks?.insert(track, at: index)
            throw error
        }
    }
    
    @MainActor
    private func likePlaylist(_ playlist: Playlist) async throws {
        guard !myLikedPlaylistIds.contains(playlist.id) else {
            return // throw?
        }
        myLikedPlaylistIds.insert(playlist.id, at: 0)
        do {
            try await service.likePlaylist(playlist)
        } catch {
            // Undo local operation if network operation fails
            myLikedPlaylistIds.removeFirst()
            throw error
        }
    }
    
    @MainActor
    private func unlikePlaylist(_ playlist: Playlist) async throws {
        guard let index = myLikedPlaylistIds.firstIndex(of: playlist.id) else {
            return // throw?
        }
        myLikedPlaylistIds.remove(at: index)
        do {
            try await service.unlikePlaylist(playlist)
        } catch {
            // Undo local operation if network operation fails
            myLikedPlaylistIds.insert(playlist.id, at: index)
            throw error
        }
    }
}

// MARK: - Queue Helpers 📜
extension AudioStore {
    var isLoadedTrackDownloaded: Bool {
        guard let loadedTrack else { return false }
        return downloadedTracks.contains(loadedTrack)
    }
    
    @MainActor
    func setNowPlayingQueue(with tracks: [Track]) {
        loadedPlaylists[PlaylistType.nowPlaying.rawValue]?.tracks = tracks
    }
    
    var nowPlayingQueue: [Track]? {
        loadedPlaylists[PlaylistType.nowPlaying.rawValue]?.tracks
    }
    
    var nextTrackInNowPlayingQueue: Track? {
        guard let queue = nowPlayingQueue
        else { return nil }
        
        let isEndOfQueue = loadedTrackPlaylistIndex == queue.count - 1
        let nextTrackIndex = isEndOfQueue ? 0 : loadedTrackPlaylistIndex + 1
        return queue[nextTrackIndex]
    }
    
    var previousTrackInNowPlayingQueue: Track? {
        guard let queue = nowPlayingQueue,
              loadedTrackPlaylistIndex > 0
        else { return nil }
        
        let previousTrackIndex = loadedTrackPlaylistIndex - 1
        return queue[previousTrackIndex]
    }
}

// MARK: - 💾 Now Playing Info
extension AudioStore {
    func saveNowPlayingInfo(withProgress progress: Double) {
        guard let loadedTrack, let nowPlayingQueue else {
            return
        }
        try? nowPlayingInfoDAO.save(NowPlayingInfo(progress: progress, track: loadedTrack, queue: nowPlayingQueue))
    }
    
    @MainActor
    func loadNowPlayingInfo() async {
        guard var nowPlayingInfo = try? nowPlayingInfoDAO.get() else {
            return
        }
        
        if let downloadedTrack = downloadedTracks.first(where: { $0.id == nowPlayingInfo.track.id }) {
            loadedTrack = downloadedTrack
            nowPlayingInfo.track = downloadedTrack
            nowPlayingInfo.queue = downloadedTracks
        } else {
            loadedTrack = nowPlayingInfo.track
        }
        
        setNowPlayingQueue(with: nowPlayingInfo.queue)
        
        NotificationCenter.default.post(
            name: .loadedNowPlayingInfo,
            object: nil,
            userInfo: ["info" : nowPlayingInfo]
        )
    }
    
    func deleteNowPlayingInfo() {
        try? nowPlayingInfoDAO.delete()
    }
}

// MARK: - Downloads 📲
extension AudioStore {
    func download(_ track: Track) async throws {
        let streamInfo = try await service.getStreamInfoForTrack(with: track.id)
        try await downloadTrack(track, from: streamInfo.httpMp3128URL)
    }
    
    @MainActor
    func removeDownload(_ trackToRemove: Track) throws {
        let trackMp3Url = trackToRemove.localFileUrl(withExtension: Track.FileExtension.mp3)
        let trackJsonUrl = trackToRemove.localFileUrl(withExtension: Track.FileExtension.json)
        do {
            try FileManager.default.removeItem(at: trackMp3Url)
            try FileManager.default.removeItem(at: trackJsonUrl)
            downloadedTracks.removeAll(where: { $0.id == trackToRemove.id })
        } catch {
            throw Error.removingDownloadedTrack
        }
    }
    
    @MainActor func removeAllDownloads() throws {
        for track in downloadedTracks {
            try removeDownload(track)
        }
    }
    
    @MainActor
    func cancelDownloadInProgress(for track: Track) throws {
        guard downloadsInProgress.keys.contains(track), let task = downloadTasks[track] else {
            throw Error.trackDownloadNotInProgress
        }
        task.cancel()
        downloadTasks.removeValue(forKey: track)
        downloadsInProgress.removeValue(forKey: track)
    }
    
    var downloadedTracksFileSize: Double { // in MB
        downloadedTracks
            .map(\.fileSizeInMb)
            .reduce(0.0, +)
    }
}

// MARK: - Private Downloads 🙈
private extension AudioStore {
    
    @MainActor
    func downloadTrack(_ track: Track, from url: String) async throws {
        // Checks before starting download...
        // Is downloading over cellular allowed?
        if PathMonitor.shared.currentPath.isCellular && !Config.allowDownloadingUsingData {
            throw Error.downloadingWithCellularDisabled
        }
        // Is track already downloaded?
        let localMp3Url = track.localFileUrl(withExtension: Track.FileExtension.mp3)
        let localFileDoesNotExist = !FileManager.default.fileExists(atPath: localMp3Url.path)
        let downloadNotAlreadyInProgress = !downloadsInProgress.keys.contains(track)
        guard localFileDoesNotExist, downloadNotAlreadyInProgress else {
            throw Error.downloadAlreadyExists
        }
        // Set empty progress for track so didCreateTask can know which track it's starting download for
        downloadsInProgress[track] = Progress(totalUnitCount: 0)
        // Setup request
        var request = URLRequest(url: URL(string: url)!)
        request.allHTTPHeaderFields = try await service.authenticatedHeader
        // ‼️ Response does not contain ID for track (only encrypted ID)
        // Add track ID to request header to know which track is being downloaded in delegate
        request.addValue("\(track.id)", forHTTPHeaderField: "track_id")
        // Make request for track data
        guard let (trackData, response) = try? await URLSession.shared.data(for: request, delegate: self) else {
            throw Error.noInternet
        }
        let statusCodeInt = (response as! HTTPURLResponse).statusCode
        let statusCode = SoundCloud.StatusCode(rawValue: statusCodeInt) ?? .unknown
        guard statusCode != SoundCloud.StatusCode.unauthorized else {
            throw Error.userNotAuthorized
        }
        guard !statusCode.errorOccurred else {
            throw Error.network(statusCode)
        }
        // Download completed successfully...
        downloadsInProgress.removeValue(forKey: track)
        // Save track data as mp3
        try trackData.write(to: localMp3Url)
        // Save track metadata as track json object
        let trackJsonData = try encoder.encode(track)
        let localJsonUrl = track.localFileUrl(withExtension: Track.FileExtension.json)
        try trackJsonData.write(to: localJsonUrl)
        // Create copy of track with local file url added
        var trackWithLocalFileUrl = track
        trackWithLocalFileUrl.localFileUrl = localMp3Url.absoluteString
        downloadedTracks.append(trackWithLocalFileUrl)
    }
    
    @MainActor
    func loadDownloadedTracks() throws {
        // Get id of downloaded tracks from device's documents directory
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let downloadedTrackIdList = try FileManager.default.contentsOfDirectory(atPath: documentsURL.path)
            .filter { $0.lowercased().contains(Track.FileExtension.mp3) } // Get all mp3 files
            .map { $0.replacingOccurrences(of: ".\(Track.FileExtension.mp3)", with: "") } // Remove mp3 extension so only id remains
        
        // Load track for each id, set local mp3 file url for track
        var loadedTracks = [Track]()
        for id in downloadedTrackIdList {
            let trackJsonURL = documentsURL.appendingPathComponent("\(id).\(Track.FileExtension.json)")
            let trackJsonData = try Data(contentsOf: trackJsonURL)
            var downloadedTrack = try decoder.decode(Track.self, from: trackJsonData)
            
            let downloadedTrackLocalMp3Url = downloadedTrack.localFileUrl(withExtension: Track.FileExtension.mp3).absoluteString
            downloadedTrack.localFileUrl = downloadedTrackLocalMp3Url
            
            loadedTracks.append(downloadedTrack)
        }
        downloadedTracks = loadedTracks
    }
}

extension AudioStore: URLSessionTaskDelegate {
    
    @MainActor
    func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        // ‼️ Get track id being downloaded from request header field
        guard
            let trackId = Int(task.originalRequest?.value(forHTTPHeaderField: "track_id") ?? ""),
            let trackBeingDownloaded = downloadsInProgress.keys.first(where: { $0.id == trackId })
        else { return }
        // Keep reference to task in case we need to cancel
        downloadTasks[trackBeingDownloaded] = task
        // Assign task's progress to track being downloaded
        task.publisher(for: \.progress)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                DispatchQueue.main.async { // Not sure if this works better than .receive(on:) alone
                    self?.downloadsInProgress[trackBeingDownloaded] = progress
                }
            }
            .store(in: &subscriptions)
    }
}

extension AudioStore {
    enum Error: LocalizedError, Equatable {
        case gettingTracksForUser
        case gettingLikedTracksForUser
        case gettingTracksForPlaylist
        case gettingPageOfTracks
        case gettingPageOfPlaylists
        
        case loadingMyPlaylists
        case loadingMyLikedPlaylists
        
        case togglingLikedTrack
        case togglingLikedPlaylist
        
        case trackDownloadNotInProgress
        case downloadAlreadyExists
        case downloadingWithCellularDisabled
        
        case userNotAuthorized
        case network(SoundCloud.StatusCode)
        case invalidURL
        case noInternet
        case removingDownloadedTrack
        
        var errorDescription: String? {
            switch self {
            case .togglingLikedTrack: String(localized: "There was a problem liking/unliking the song", comment: "Error message")
            case .downloadAlreadyExists: String(localized: "Download already exists", comment: "Error message")
            case .downloadingWithCellularDisabled: String(localized: "Downloading with a cellular connection is disabled, go to Settings to enable", comment: "Error message")
            case .removingDownloadedTrack: String(localized: "There was a problem removing the download", comment: "Error message")
            default: nil
            }
        }
    }
}

fileprivate extension Track {
    enum FileExtension {
        public static let mp3 = "mp3"
        public static let json = "json"
    }
    
    var fileSizeInMb: Double {
        Double(durationInSeconds) * 0.015996 // SoundCloud mp3's are 0.015996 MB / second
    }
}
