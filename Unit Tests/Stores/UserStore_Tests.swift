//
//  UserStore_Tests.swift
//  Unit Tests
//
//  Created by Ryan Forsyth on 2023-11-12.
//

import SoundCloud
import XCTest
@testable import WatchCloud_Watch_App

final class UserStore_Tests: XCTestCase {
    
    var sut: UserStore!
    var mockService = MockSoundCloud()
    var mockDAO = MockDAO<User>()
    
    func test_reset_updatesLocalState_andDAO() async throws {
        // Given
        let expectedMyUser = testUser()
        let expectedUsersImFollowing = [testUser(), testUser()]
        mockService.myUser = expectedMyUser
        mockService.usersToReturn = expectedUsersImFollowing
        sut = await UserStore(mockService, mockDAO)
        // When
        try await sut.load()
        // Then
        var myUser = await sut.myUser
        var usersImFollowing = await sut.usersImFollowing.items
        XCTAssertEqual(myUser, expectedMyUser)
        XCTAssertEqual(usersImFollowing, expectedUsersImFollowing)
        // When
        await sut.reset()
        // Then
        myUser = await sut.myUser
        usersImFollowing = await sut.usersImFollowing.items
        XCTAssertNil(myUser)
        XCTAssertTrue(usersImFollowing.isEmpty)
        
    }
    
    func test_loadMyProfile_loadsUserFromDAO_whenDAOContainsUser() async throws {
        // Given
        let expectedUser = testUser()
        mockDAO.persistedValue = expectedUser
        sut = await UserStore(mockService, mockDAO)
        // When
        try await sut.loadMyProfile()
        // Then
        let loadedUser = await sut.myUser
        XCTAssertEqual(loadedUser, expectedUser)
    }
    
    func test_loadMyProfile_loadsUserFromService_andSavesToDAO() async throws {
        // Given
        let expectedUser = testUser()
        mockDAO.persistedValue = nil
        mockService.myUser = expectedUser
        sut = await UserStore(mockService, mockDAO)
        // When
        try await sut.loadMyProfile()
        // Then
        let loadedUser = await sut.myUser
        XCTAssertEqual(loadedUser, expectedUser)
        XCTAssertEqual(mockDAO.persistedValue, expectedUser)
    }
    
    func test_loadMyProfile_whenDAOIsEmpty_andServiceThrowsError() async throws {
        // Given
        mockDAO.persistedValue = nil
        mockService.shouldThrowError = true
        sut = await UserStore(mockService, mockDAO)
        do {// When
            try await sut.loadMyProfile()
            XCTFail("Should have thrown error")
        } catch { // Then
            XCTAssertEqual(error as? MockError, MockError.mock)
        }
    }
    
    func test_loadUsersImFollowing_loadsUsersFromService() async throws {
        // Given
        let expectedUsers = [testUser(), testUser()]
        mockService.usersToReturn = expectedUsers
        sut = await UserStore(mockService)
        // When
        try await sut.loadUsersImFollowing()
        // Then
        let usersImFollowing = await sut.usersImFollowing.items
        XCTAssertEqual(usersImFollowing, expectedUsers)
    }
    
    func test_loadUsersImFollowing_loadsNextPage() async throws {
        // Given
        let followedUsers = [testUser(), testUser()]
        let otherFollowedUsers = [testUser(), testUser()]
        mockService.usersToReturn = followedUsers
        sut = await UserStore(mockService)
        // When
        try await sut.loadUsersImFollowing()
        mockService.usersToReturn = otherFollowedUsers
        try await sut.loadUsersImFollowing()
        // Then
        let usersImFollowing = await sut.usersImFollowing.items
        XCTAssertEqual(usersImFollowing, followedUsers + otherFollowedUsers)
    }
    
    func test_loadUsersImFollowing_whenServiceThrowsError() async throws {
        // Given
        mockService.shouldThrowError = true
        sut = await UserStore(mockService)
        do {// When
            try await sut.loadUsersImFollowing()
            XCTFail("Should have thrown error")
        } catch { // Then
            XCTAssertEqual(error as? MockError, MockError.mock)
        }
    }
    
    func test_followUser_updatesLocalState() async throws {
        // Given
        let userToFollow = testUser()
        sut = await UserStore(mockService)
        // When
        try await sut.followUser(userToFollow)
        // Then
        let followedUsers = await sut.usersImFollowing.items
        XCTAssertTrue(followedUsers.contains(userToFollow))
    }
    
    func test_followUser_withDuplicateUsers_doesNotDuplicateLocalState() async throws {
        // Given
        let userToFollow = testUser()
        sut = await UserStore(mockService)
        // When
        try await sut.followUser(userToFollow)
        try await sut.followUser(userToFollow)
        // Then
        let followedUsers = await sut.usersImFollowing.items
        XCTAssertEqual(followedUsers.count, 1)
    }
    
    func test_followUser_throwsErrorAndRemovesLikedUser_whenServiceThrowsError() async {
        // Given
        mockService.shouldThrowError = true
        sut = await UserStore(mockService)
        do { // When
            try await sut.followUser(testUser())
        } catch { // Then
            XCTAssertEqual(error as? MockError, MockError.mock)
            let followedUsers = await sut.usersImFollowing.items
            XCTAssertTrue(followedUsers.isEmpty)
        }
    }
    
    func test_unfollowUser_updatesUsersImFollowing() async throws {
        // Given
        let userToUnfollow = testUser()
        sut = await UserStore(mockService)
        // When
        try await sut.followUser(userToUnfollow)
        try await sut.unfollowUser(userToUnfollow)
        // Then
        let followedUsers = await sut.usersImFollowing.items
        XCTAssertTrue(followedUsers.isEmpty)
    }
    
    func test_unfollowUser_doesNothingIfUserNotAlreadyFollowed() async throws {
        // Given
        sut = await UserStore(mockService)
        // When
        try await sut.unfollowUser(testUser())
        // Then
        let followedUsers = await sut.usersImFollowing.items
        XCTAssertTrue(followedUsers.isEmpty)
    }
    
    func test_unfollowUser_throwsErrorAndReinsertsLikedUser_whenServiceThrowsError() async {
        // Given
        let userToUnfollow = testUser()
        mockService.shouldThrowError = false
        sut = await UserStore(mockService)
        do {
            try await sut.followUser(userToUnfollow)
            mockService.shouldThrowError = true
            // When
            try await sut.unfollowUser(userToUnfollow)
        } catch { // Then
            XCTAssertEqual(error as? MockError, MockError.mock)
            let followedUsers = await sut.usersImFollowing.items
            XCTAssertTrue(followedUsers.contains(userToUnfollow), "Followed users should still contain user if service fails to unfollow")
        }
    }
    
    func test_pageOfUsers_whenServiceThrowsError() async {
        // Given
        mockService.shouldThrowError = true
        sut = await UserStore(mockService)
        do { // When
            _ = try await sut.pageOfUsers("mock")
            XCTFail("Should have thrown error")
        } catch { // Then
            XCTAssertEqual(error as? MockError, MockError.mock)
        }
    }
}
