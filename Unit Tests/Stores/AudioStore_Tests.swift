//
//  AudioStore_Tests.swift
//  Unit Tests
//
//  Created by Ryan Forsyth on 2023-11-12.
//

import SoundCloud
import XCTest
@testable import WatchCloud_Watch_App

final class AudioStore_Tests: XCTestCase {
    
    var sut: AudioStore!
    var mockService = MockSoundCloud()
    
    func test_load_loadsAllSystemPlaylistTypes() async throws {
        // Given
        mockService.playlistsToReturn = [testPlaylist(), testPlaylist()]
        sut = AudioStore(mockService)
        // When
        try await sut.load()
        // Then
        let loadedPlaylistIds = sut.loadedPlaylists.keys
        for type in PlaylistType.allCases {
            XCTAssertTrue(loadedPlaylistIds.contains(type.rawValue))
        }
    }
    
    func test_load_whenServiceThrowsError() async {
        // Given
        let expectedError = AudioStore.Error.loadingMyPlaylists
        mockService.shouldThrowError = true
        sut = AudioStore(mockService)
        do { // When
            try await sut.load()
        } catch { // Then
            XCTAssertEqual(error as! AudioStore.Error, expectedError)
        }
    }

    func test_getTracksForUser_returnsTracksFromService() async throws {
        // Given
        let expectedTracks = [testTrack(), testTrack()]
        mockService.tracksToReturn = expectedTracks
        sut = AudioStore(mockService)
        // When
        let tracksForUser = try await sut.getTracksForUser(123).items
        // Then
        XCTAssertEqual(expectedTracks, tracksForUser)
    }
    
    func test_getTracksForUser_whenServiceThrowsError() async {
        // Given
        let expectedError = AudioStore.Error.gettingTracksForUser
        mockService.shouldThrowError = true
        sut = AudioStore(mockService)
        do { // When
            _ = try await sut.getTracksForUser(123)
            XCTFail("Should have thrown error")
        } catch { // Then
            XCTAssertEqual(error as! AudioStore.Error, expectedError)
        }
    }
    
    func test_getLikedTracksForUser_returnsTracksFromService() async throws {
        // Given
        let expectedTracks = [testTrack(), testTrack()]
        mockService.tracksToReturn = expectedTracks
        sut = AudioStore(mockService)
        // When
        let likedTracksForUser = try await sut.getLikedTracksForUser(123).items
        // Then
        XCTAssertEqual(expectedTracks, likedTracksForUser)
    }
    
    func test_getLikedTracksForUser_whenServiceThrowsError() async {
        // Given
        let expectedError = AudioStore.Error.gettingLikedTracksForUser
        mockService.shouldThrowError = true
        sut = AudioStore(mockService)
        do { // When
            _ = try await sut.getLikedTracksForUser(123)
            XCTFail("Should have thrown error")
        } catch { // Then
            XCTAssertEqual(error as! AudioStore.Error, expectedError)
        }
    }
    
    func test_getTracksForPlaylist_returnsTracksFromService() async throws {
        // Given
        let expectedTracks = [testTrack(), testTrack()]
        mockService.tracksToReturn = expectedTracks
        sut = AudioStore(mockService)
        // When
        let tracksForPlaylist = try await sut.getTracksForPlaylist(123).items
        // Then
        XCTAssertEqual(expectedTracks, tracksForPlaylist)
    }
    
    func test_getTracksForPlaylist_whenServiceThrowsError() async {
        // Given
        let expectedError = AudioStore.Error.gettingTracksForPlaylist
        mockService.shouldThrowError = true
        sut = AudioStore(mockService)
        do { // When
            _ = try await sut.getTracksForPlaylist(123)
            XCTFail("Should have thrown error")
        } catch { // Then
            XCTAssertEqual(error as! AudioStore.Error, expectedError)
        }
    }
    
    func test_getPageOfTracks_returnsTracksFromService() async throws {
        // Given
        let expectedTracks = [testTrack(), testTrack()]
        mockService.tracksToReturn = expectedTracks
        sut = AudioStore(mockService)
        // When
        let tracksForPage = try await sut.pageOfTracks("123").items
        // Then
        XCTAssertEqual(expectedTracks, tracksForPage)
    }
    
    func test_getPageOfTracks_whenServiceThrowsError() async {
        // Given
        let expectedError = AudioStore.Error.gettingPageOfTracks
        mockService.shouldThrowError = true
        sut = AudioStore(mockService)
        do { // When
            _ = try await sut.pageOfTracks("123")
            XCTFail("Should have thrown error")
        } catch { // Then
            XCTAssertEqual(error as! AudioStore.Error, expectedError)
        }
    }
    
    func test_getPageOfPlaylists_returnsPlaylistsFromService() async throws {
        // Given
        let expectedPlaylists = [testPlaylist(), testPlaylist()]
        mockService.playlistsToReturn = expectedPlaylists
        sut = AudioStore(mockService)
        // When
        let playlistsForPage = try await sut.pageOfPlaylists("123").items
        // Then
        XCTAssertEqual(expectedPlaylists, playlistsForPage)
    }
    
    func test_getPageOfPlaylists_whenServiceThrowsError() async {
        // Given
        let expectedError = AudioStore.Error.gettingPageOfPlaylists
        mockService.shouldThrowError = true
        sut = AudioStore(mockService)
        do { // When
            _ = try await sut.pageOfPlaylists("123")
            XCTFail("Should have thrown error")
        } catch { // Then
            XCTAssertEqual(error as! AudioStore.Error, expectedError)
        }
    }
    
    func test_toggleLikedTrack_likesAndUnlikesTrack() async throws {
        // Given
        let trackToLike = testTrack(isLiked: false)
        sut = AudioStore(mockService)
        try await sut.load()
        // When
        try await sut.toggleLikedTrack(trackToLike)
        // Then
        var isLiked = sut.isLiked(trackToLike)
        XCTAssertTrue(isLiked)
        // When
        try await sut.toggleLikedTrack(trackToLike)
        // Then
        isLiked = sut.isLiked(trackToLike)
        XCTAssertFalse(isLiked)
    }
    
    func test_toggleLikedTrack_whenServiceThrowsError() async {
        // Given
        let trackToLike = testTrack(isLiked: false)
        let expectedError = AudioStore.Error.togglingLikedTrack
        mockService.shouldThrowError = true
        sut = AudioStore(mockService)
        var isLiked = sut.isLiked(trackToLike)
        XCTAssertFalse(isLiked)
        do { // When
            try await sut.toggleLikedTrack(trackToLike)
            XCTFail("Should have thrown error")
        } catch { // Then
            XCTAssertEqual(expectedError, error as! AudioStore.Error)
            isLiked = sut.isLiked(trackToLike)
            XCTAssertFalse(isLiked, "Track should not be liked if service threw error")
        }
    }
    
    func test_toggleLikedPlaylist_likesAndUnlikesPlaylist() async throws {
        // Given
        let playlistToLike = testPlaylist()
        sut = AudioStore(mockService)
        // When
        try await sut.toggleLikedPlaylist(playlistToLike)
        // Then
        var isLiked = sut.isLiked(playlistToLike)
        XCTAssertTrue(isLiked)
        // When
        try await sut.toggleLikedPlaylist(playlistToLike)
        // Then
        isLiked = sut.isLiked(playlistToLike)
        XCTAssertFalse(isLiked)
    }
    
    func test_toggleLikedPlaylist_whenServiceThrowsError() async {
        // Given
        let playlistToLike = testPlaylist()
        let expectedError = AudioStore.Error.togglingLikedPlaylist
        mockService.shouldThrowError = true
        sut = AudioStore(mockService)
        var isLiked = sut.isLiked(playlistToLike)
        XCTAssertFalse(isLiked)
        do { // When
            try await sut.toggleLikedPlaylist(playlistToLike)
            XCTFail("Should have thrown error")
        } catch { // Then
            XCTAssertEqual(expectedError, error as! AudioStore.Error)
            isLiked = sut.isLiked(playlistToLike)
            XCTAssertFalse(isLiked, "Playlist should not be liked if service threw error")
        }
    }
    
    func test_nowPlayingQueueNextAndPreviousTracks() async throws {
        // Given
        let firstTrack = testTrack()
        let secondTrack = testTrack()
        let lastTrack = testTrack()
        let queueWithThreeTracks = [firstTrack, secondTrack, lastTrack]
        
        sut = AudioStore(mockService)
        try await sut.load()
        
        // When
        await sut.setNowPlayingQueue(with: queueWithThreeTracks)
        sut.loadedTrack = secondTrack
        // Then
        XCTAssertEqual(sut.previousTrackInNowPlayingQueue, firstTrack)
        XCTAssertEqual(sut.nextTrackInNowPlayingQueue, lastTrack)
        
        // When
        sut.loadedTrack = lastTrack
        // Then next track should be first in queue
        XCTAssertEqual(sut.nextTrackInNowPlayingQueue, firstTrack)
        
        // When
        sut.loadedTrack = firstTrack
        XCTAssertNil(sut.previousTrackInNowPlayingQueue)
    }
    
    func test_loadTracksForPlaylist_withUserPlaylistTypes() async throws {
        // Given
        let playlistIdList = PlaylistType.allCases.map(\.rawValue)
        sut = AudioStore(mockService)
        try await sut.load()
        // When
        for id in playlistIdList {
            try await sut.loadTracksForPlaylist(with: id)
        }
        // Then
        for id in playlistIdList {
            XCTAssertNotNil(sut.loadedPlaylists[id])
        }
    }
}
