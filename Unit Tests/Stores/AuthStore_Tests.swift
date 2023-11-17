//
//  AuthStore_Tests.swift
//  Unit Tests
//
//  Created by Ryan Forsyth on 2023-11-11.
//

import SoundCloud
import XCTest
@testable import WatchCloud_Watch_App

final class AuthStore_Tests: XCTestCase {
    
    var sut: AuthStore!
    var mockService = MockSoundCloud()
    
    func test_loginAndLogout_updatePublishedState() async throws {
        // Given
        mockService.shouldThrowError = false
        sut = AuthStore(mockService)
        // When
        try await sut.login()
        // Then
        XCTAssertTrue(sut.isLoggedIn)
        // When
        sut.logout()
        // Then
        XCTAssertFalse(sut.isLoggedIn)
    }
    
    func test_loginFailure_whenServiceThrowsError() async {
        // Given
        let expectedError = AuthStore.Error.loggingIn
        mockService.shouldThrowError = true
        sut = AuthStore(mockService)
        do { // When
            try await sut.login()
            XCTFail("Error should have been thrown")
        } catch { // Then
            XCTAssertEqual(expectedError, error as! AuthStore.Error)
            XCTAssertFalse(sut.isLoggedIn)
        }
    }
    
    func test_storeUsesAuthenticatedHeaderFromService() async throws {
        // Given
        let expectedHeader = ["expected" : "header"]
        mockService.authenticatedHeader = expectedHeader
        sut = AuthStore(mockService)
        // When
        let headerFromStore = try await sut.authHeader
        // Then
        XCTAssertEqual(headerFromStore, expectedHeader)
    }
}
