//
//  MockSoundCloud.swift
//  Unit Tests
//
//  Created by Ryan Forsyth on 2023-11-01.
//

import SoundCloud
@testable import WatchCloud_Watch_App

final class MockSoundCloud: SoundCloudAPI, AuthService {
    
    var shouldThrowError = false
    var myUser: User = testUser()
    var loginTokenResponse = TokenResponse.test
    var tracksToReturn: [Track] = []
    var playlistsToReturn: [Playlist] = []
    var usersToReturn: [User] = []
    
    func login() async throws -> TokenResponse {
        if shouldThrowError { throw MockError.mock }
        return loginTokenResponse
    }
    
    func logout() {
        /* Not implemented */
    }
    
    var authenticatedHeader = ["mock" : "header"]
    
    func getMyUser() async throws -> User {
        if shouldThrowError { throw MockError.mock }
        return myUser
    }
    
    func getUsersImFollowing() async throws -> Page<User> {
        if shouldThrowError { throw MockError.mock }
        return Page<User>(items: usersToReturn, nextPage: "mock")
    }
    
    func getMyLikedTracks() async throws -> Page<Track> {
        if shouldThrowError { throw MockError.mock }
        return Page<Track>(items: tracksToReturn, nextPage: "mock")
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
        return Page<Track>(items: tracksToReturn, nextPage: "mock")
    }
    
    func getTracksForUser(_ id: Int, _ limit: Int) async throws -> Page<Track> {
        if shouldThrowError { throw MockError.mock }
        return Page<Track>(items: tracksToReturn, nextPage: "mock")
    }
    
    func getLikedTracksForUser(_ id: Int, _ limit: Int) async throws -> Page<Track> {
        if shouldThrowError { throw MockError.mock }
        return Page<Track>(items: tracksToReturn, nextPage: "mock")
    }
    
    func getRelatedTracks(_ id: Int, _ limit: Int) async throws -> Page<Track> {
        if shouldThrowError { throw MockError.mock }
        return Page<Track>(items: tracksToReturn, nextPage: "mock")
    }
    
    func searchTracks(_ query: String, _ limit: Int) async throws -> Page<Track> {
        if shouldThrowError { throw MockError.mock }
        return Page<Track>(items: tracksToReturn, nextPage: "mock")
    }
    
    func searchPlaylists(_ query: String, _ limit: Int) async throws -> Page<Playlist> {
        if shouldThrowError { throw MockError.mock }
        return Page<Playlist>(items: playlistsToReturn, nextPage: "mock")
    }
    
    func searchUsers(_ query: String, _ limit: Int) async throws -> Page<User> {
        if shouldThrowError { throw MockError.mock }
        return Page<User>(items: usersToReturn, nextPage: "mock")
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
        
        if ItemType.self == Track.self {
            return Page<ItemType>(items: tracksToReturn as! [ItemType], nextPage: "mock")
        } else if ItemType.self == User.self {
            return Page<ItemType>(items: usersToReturn as! [ItemType], nextPage: "mock")
        } else if ItemType.self == Playlist.self {
            return Page<ItemType>(items: playlistsToReturn as! [ItemType], nextPage: "mock")
        }
        
        return Page<ItemType>(items: [], nextPage: "mock")
    }
    
    func getStreamInfoForTrack(with id: Int) async throws -> StreamInfo {
        if shouldThrowError { throw MockError.mock }
        return testStreamInfo
    }
}

enum MockError: Error {
    case mock
}

extension TokenResponse {
    static let test = TokenResponse(accessToken: "", expiresIn: 0, refreshToken: "", scope: "", tokenType: "")
}
