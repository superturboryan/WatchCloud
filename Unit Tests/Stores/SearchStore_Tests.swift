//
//  SearchStore_Tests.swift
//  Unit Tests
//
//  Created by Ryan Forsyth on 2023-11-01.
//

import SoundCloud
import XCTest
@testable import WatchCloud_Watch_App

final class SearchStore_Tests: XCTestCase {

    var sut: SearchStore!
    var sc = MockSoundCloud()
    
    func test_searchForTracks_updatesSearchHistory() async throws {
        // Given
        let query = "123"
        let expectedTracks = [testTrack()]
        let expectedSearchEntry = SearchEntry(.tracks, query)
        sc.tracksToReturn = expectedTracks
        sut = SearchStore(sc)
        // When
        let searchResults = try await sut.searchForTracks(query)
        // Then
        XCTAssertEqual(searchResults.items, expectedTracks)
        XCTAssertEqual(sut.searchHistory.count, 1)
        XCTAssertEqual(sut.searchHistory.first!, expectedSearchEntry)
    }
    
    func test_searchForPlaylists_updatesSearchHistory() async throws {
        // Given
        let query = "123"
        let expectedPlaylists = [testPlaylist()]
        let expectedSearchEntry = SearchEntry(.playlists, query)
        sc.playlistsToReturn = expectedPlaylists
        sut = SearchStore(sc)
        // When
        let searchResults = try await sut.searchForPlaylists(query)
        // Then
        XCTAssertEqual(searchResults.items, expectedPlaylists)
        XCTAssertEqual(sut.searchHistory.count, 1)
        XCTAssertEqual(sut.searchHistory.first!, expectedSearchEntry)
    }
    
    func test_searchForUsers_updatesSearchHistory() async throws {
        // Given
        let query = "123"
        let expectedUsers = [testUser()]
        let expectedSearchEntry = SearchEntry(.artists, query)
        sc.usersToReturn = expectedUsers
        sut = SearchStore(sc)
        // When
        let searchResults = try await sut.searchForUsers(query)
        // Then
        XCTAssertEqual(searchResults.items, expectedUsers)
        XCTAssertEqual(sut.searchHistory.count, 1)
        XCTAssertEqual(sut.searchHistory.first!, expectedSearchEntry)
    }
    
    func test_searchHistoryCapacity() async throws {
        // Given
        let searchCapacity = 2
        let query1 = "123"
        let query2 = "456"
        let query3 = "789"
        sut = SearchStore(sc, searchHistoryCapacity: searchCapacity)
        // When
        _ = try await sut.searchForUsers(query1)
        _ = try await sut.searchForUsers(query2)
        _ = try await sut.searchForUsers(query3)
        _ = try await sut.searchForUsers(query2) // Search again using already used query
        // Then
        XCTAssertEqual(sut.searchHistory.count, searchCapacity)
        XCTAssertTrue(!sut.searchHistory.map(\.query).contains(query1))
        XCTAssertTrue(sut.searchHistory.map(\.query).contains([query2, query3]))
    }
    
    func test_load_and_reset() throws {
        // Given
        let expectedSearchEntries = [SearchEntry(.tracks, "123"), SearchEntry(.playlists, "456")]
        let historyDAO = MockDAO<[SearchEntry]>()
        try historyDAO.save(expectedSearchEntries)
        sut = SearchStore(sc, historyDAO)
        // When
        XCTAssertTrue(sut.searchHistory.isEmpty)
        sut.load()
        // Then
        XCTAssertEqual(sut.searchHistory, expectedSearchEntries)
        // When
        sut.reset()
        // Then
        XCTAssertTrue(sut.searchHistory.isEmpty)
        XCTAssertNil(historyDAO.valueToReturn)
    }
}
