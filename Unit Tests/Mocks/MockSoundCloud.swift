//
//  MockSoundCloud.swift
//  Unit Tests
//
//  Created by Ryan Forsyth on 2023-11-01.
//

import SoundCloud
@testable import WatchCloud_Watch_App

final class MockSoundCloud: SoundCloudAPI {
    var shouldThrowError = false
    var myUser: User = testUser()
    var tracksToReturn: [Track] = []
    var playlistsToReturn: [Playlist] = []
    var usersToReturn: [User] = []
    
    func login() async throws {
        if shouldThrowError { throw MockError.mock }
    }
    
    func logout() { /* Not implemented */ }
    
    var authenticatedHeader = ["mock" : "header"]
    
    func getMyUser() async throws -> User {
        if shouldThrowError { throw MockError.mock }
        return myUser
    }
    
    func getUsersImFollowing() async throws -> Page<User> {
        if shouldThrowError { throw MockError.mock }
        return Page<User>(items: usersToReturn)
    }
    
    func getMyLikedTracks() async throws -> Page<Track> {
        if shouldThrowError { throw MockError.mock }
        return Page<Track>(items: tracksToReturn)
    }
    
    func getMyFollowingsRecentlyPosted() async throws -> [Track] {
        if shouldThrowError { throw MockError.mock }
        return tracksToReturn
    }
    
    func getMyPlaylistsWithoutTracks() async throws -> [Playlist] {
        if shouldThrowError { throw MockError.mock }
        return playlistsToReturn
    }
    
    func getMyLikedPlaylistsWithoutTracks() async throws -> [Playlist] {
        if shouldThrowError { throw MockError.mock }
        return playlistsToReturn
    }
    
    func getTracksForPlaylist(_ id: Int) async throws -> Page<Track> {
        if shouldThrowError { throw MockError.mock }
        return Page<Track>(items: tracksToReturn)
    }
    
    func getTracksForUser(_ id: Int, _ limit: Int) async throws -> Page<Track> {
        if shouldThrowError { throw MockError.mock }
        return Page<Track>(items: tracksToReturn)
    }
    
    func getLikedTracksForUser(_ id: Int, _ limit: Int) async throws -> Page<Track> {
        if shouldThrowError { throw MockError.mock }
        return Page<Track>(items: tracksToReturn)
    }
    
    func searchTracks(_ query: String, _ limit: Int) async throws -> Page<Track> {
        if shouldThrowError { throw MockError.mock }
        return Page<Track>(items: tracksToReturn)
    }
    
    func searchPlaylists(_ query: String, _ limit: Int) async throws -> Page<Playlist> {
        if shouldThrowError { throw MockError.mock }
        return Page<Playlist>(items: playlistsToReturn)
    }
    
    func searchUsers(_ query: String, _ limit: Int) async throws -> Page<User> {
        if shouldThrowError { throw MockError.mock }
        return Page<User>(items: usersToReturn)
    }
    
    func likeTrack(_ likedTrack: Track) async throws {
        if shouldThrowError { throw MockError.mock }
    }
    
    func unlikeTrack(_ unlikedTrack: Track) async throws {
        if shouldThrowError { throw MockError.mock }
    }
    
    func likePlaylist(_ playlist: Playlist) async throws {
        if shouldThrowError { throw MockError.mock }
    }
    
    func unlikePlaylist(_ playlist: Playlist) async throws {
        if shouldThrowError { throw MockError.mock }
    }
    
    func followUser(_ user: User) async throws {
        if shouldThrowError { throw MockError.mock }
    }
    
    func unfollowUser(_ user: User) async throws {
        if shouldThrowError { throw MockError.mock }
    }
    
    func pageOfItems<ItemType>(for href: String) async throws -> Page<ItemType> where ItemType : Decodable {
        if shouldThrowError { throw MockError.mock }
        return Page<ItemType>(items: [])
    }
    
    func getStreamInfoForTrack(with id: Int) async throws -> StreamInfo {
        if shouldThrowError { throw MockError.mock }
        return testStreamInfo
    }
}

enum MockError: Error {
    case mock
}
