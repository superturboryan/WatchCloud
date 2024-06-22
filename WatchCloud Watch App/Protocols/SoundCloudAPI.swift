//
//  SoundCloudAPI.swift
//  
//
//  Created by Ryan Forsyth on 2023-10-27.
//

import SoundCloud

protocol SoundCloudAPI {
    func login() async throws -> TokenResponse
    func logout()
    var authenticatedHeader: [String : String] { get async throws }
    
    func getMyUser() async throws -> User
    func getUsersImFollowing() async throws -> Page<User>
    func getMyLikedTracks() async throws -> Page<Track>
    func getMyFollowingsRecentlyPosted() async throws -> [Track]
    func getMyPlaylistsWithoutTracks() async throws -> [Playlist]
    func getMyLikedPlaylistsWithoutTracks() async throws -> [Playlist]
    func getTracksForPlaylist(_ id: Int) async throws -> Page<Track>
    func getTracksForUser(_ id: Int, _ limit: Int) async throws -> Page<Track>
    func getLikedTracksForUser(_ id: Int, _ limit: Int) async throws -> Page<Track>
    func getRelatedTracks(_ id: Int, _ limit: Int) async throws -> Page<Track>
    
    func searchTracks(_ query: String, _ limit: Int) async throws -> Page<Track>
    func searchPlaylists(_ query: String, _ limit: Int) async throws -> Page<Playlist>
    func searchUsers(_ query: String, _ limit: Int) async throws -> Page<User>

    func likeTrack(_ likedTrack: Track) async throws
    func unlikeTrack(_ unlikedTrack: Track) async throws
    func likePlaylist(_ playlist: Playlist) async throws
    func unlikePlaylist(_ playlist: Playlist) async throws
    func followUser(_ user: User) async throws
    func unfollowUser(_ user: User) async throws
    
    func pageOfItems<ItemType>(for href: String) async throws -> Page<ItemType>
    func getStreamInfoForTrack(with id: Int) async throws -> StreamInfo
}

extension SoundCloud: SoundCloudAPI {}
