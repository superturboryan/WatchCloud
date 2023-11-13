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
    var mockService = MockSoundCloud()
    var mockDAO = MockDAO<[SearchEntry]>()
    
    func test_searchForTracks_updatesSearchHistory() async throws {
        // Given
        let query = "123"
        let expectedTracks = [testTrack()]
        let expectedSearchEntry = SearchEntry(.tracks, query)
        mockService.tracksToReturn = expectedTracks
        sut = SearchStore(mockService)
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
        mockService.playlistsToReturn = expectedPlaylists
        sut = SearchStore(mockService)
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
        mockService.usersToReturn = expectedUsers
        sut = SearchStore(mockService)
        // When
        let searchResults = try await sut.searchForUsers(query)
        // Then
        XCTAssertEqual(searchResults.items, expectedUsers)
        XCTAssertEqual(sut.searchHistory.count, 1)
        XCTAssertEqual(sut.searchHistory.first!, expectedSearchEntry)
    }
    
    func test_search_whenServiceThrowsError() async {
        // Given
        let expectedError = SearchStore.Error.searching
        mockService.shouldThrowError = true
        sut = SearchStore(mockService)
        do { // When
            _ = try await sut.searchForUsers("123")
            XCTFail("Should have thrown error")
        } catch { // Then
            XCTAssertEqual(error as! SearchStore.Error, expectedError)
        }
        
        do { // When
            _ = try await sut.searchForTracks("123")
            XCTFail("Should have thrown error")
        } catch { // Then
            XCTAssertEqual(error as! SearchStore.Error, expectedError)
        }
        
        do { // When
            _ = try await sut.searchForPlaylists("123")
            XCTFail("Should have thrown error")
        } catch { // Then
            XCTAssertEqual(error as! SearchStore.Error, expectedError)
        }
    }
    
    func test_search_whenDAOThrowsError() async {
        // Given
        let expectedError = SearchStore.Error.updatingSearchHistory
        mockDAO.shouldThrowError = true
        sut = SearchStore(mockService, mockDAO)
        
        do { // When
            _ = try await sut.searchForTracks("123")
            XCTFail("Should have thrown error")
        } catch { // Then
            XCTAssertEqual(error as! SearchStore.Error, expectedError)
        }
        
        do { // When
            _ = try await sut.searchForPlaylists("123")
            XCTFail("Should have thrown error")
        } catch { // Then
            XCTAssertEqual(error as! SearchStore.Error, expectedError)
        }
        
        do { // When
            _ = try await sut.searchForUsers("123")
            XCTFail("Should have thrown error")
        } catch { // Then
            XCTAssertEqual(error as! SearchStore.Error, expectedError)
        }
    }
    
    func test_searchWithEmptyQuery_throwsExpectedError() async {
        // Given
        let emptyQuery = ""
        let expectedError = SearchStore.Error.emptyQuery
        sut = SearchStore(mockService)
        
        do { // When
            _ = try await sut.searchForTracks(emptyQuery)
            XCTFail("Should have throw error")
        } catch { // Then
            XCTAssertEqual(error as! SearchStore.Error, expectedError)
        }
        
        do { // When
            _ = try await sut.searchForPlaylists(emptyQuery)
            XCTFail("Should have throw error")
        } catch { // Then
            XCTAssertEqual(error as! SearchStore.Error, expectedError)
        }
        
        do { // When
            _ = try await sut.searchForUsers(emptyQuery)
            XCTFail("Should have throw error")
        } catch { // Then
            XCTAssertEqual(error as! SearchStore.Error, expectedError)
        }
    }
    
    func test_searchWithDuplicateQuery_doesntDuplicateSearchHistory() async throws {
        // Given
        let duplicateQuery = "123"
        let otherQuery = "456"
        sut = SearchStore(mockService)
        // When
        _ = try await sut.searchForUsers(duplicateQuery)
        _ = try await sut.searchForUsers(otherQuery)
        _ = try await sut.searchForUsers(duplicateQuery)
        // Then
        let searchHistoryMatchingQuery = sut.searchHistory.filter { $0.query == duplicateQuery }
        XCTAssertEqual(searchHistoryMatchingQuery.count, 1)
    }
    
    func test_searchHistoryCapacity() async throws {
        // Given
        let searchCapacity = 2
        let query1 = "123"
        let query2 = "456"
        let query3 = "789"
        sut = SearchStore(mockService, searchHistoryCapacity: searchCapacity)
        // When
        _ = try await sut.searchForUsers(query1)
        _ = try await sut.searchForTracks(query2)
        _ = try await sut.searchForPlaylists(query3)
        _ = try await sut.searchForUsers(query2) // Search again using already used query
        // Then
        XCTAssertEqual(sut.searchHistory.count, searchCapacity)
        XCTAssertTrue(!sut.searchHistory.map(\.query).contains(query1))
        XCTAssertTrue(sut.searchHistory.map(\.query).contains([query2, query3]))
    }
    
    func test_load_and_reset() async throws {
        // Given
        let expectedSearchEntries = [SearchEntry(.tracks, "123"), SearchEntry(.playlists, "456")]
        let historyDAO = MockDAO<[SearchEntry]>()
        try historyDAO.save(expectedSearchEntries)
        sut = SearchStore(mockService, historyDAO)
        // When
        XCTAssertTrue(sut.searchHistory.isEmpty)
        await sut.load()
        // Then
        XCTAssertEqual(sut.searchHistory, expectedSearchEntries)
        // When
        await sut.reset()
        // Then
        XCTAssertTrue(sut.searchHistory.isEmpty)
        XCTAssertNil(historyDAO.persistedValue)
    }
}
