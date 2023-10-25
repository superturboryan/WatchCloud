//
//  UserStore.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-18.
//

import Foundation
import SoundCloud

@MainActor
final class UserStore: ObservableObject {
    
    @Published public var myUser: User? = nil
    @Published public var usersImFollowing: Page<User> = .emptyPage
    
    // MARK: - Dependencies
    private let service: SoundCloud
    private let myUserDAO: any DAO<User>
    
    init(
        _ service: SoundCloud,
        _ myUserDAO: any DAO<User> = UserDefaultsDAO<User>("\(User.self)")
    ) {
        self.service = service
        self.myUserDAO = myUserDAO
    }
}

extension UserStore {
    func load() async throws {
        try await loadMyProfile()
        try await loadUsersImFollowing()
    }
    
    func reset() {
        try? myUserDAO.delete()
        myUser = nil
        usersImFollowing = .emptyPage
    }
    
    func loadMyProfile() async throws {
        if let savedUser = try? myUserDAO.get() {
            myUser = savedUser
        } else {
            let loadedUser = try await service.getMyUser()
            myUser = loadedUser
            try myUserDAO.save(loadedUser)
        }
    }
    
    func loadUsersImFollowing() async throws {
        if usersImFollowing.items.isEmpty {
            let response = try await service.getUsersImFollowing()
            usersImFollowing = response
        } else if let nextPageUrl = usersImFollowing.nextPage {
            let nextPage: Page<User> = try await pageOfUsers(nextPageUrl)
            usersImFollowing.update(with: nextPage)
        }
    }
    
    func followUser(_ user: User) async throws {
        guard !usersImFollowing.items.contains(user) else {
            return // throw?
        }
        usersImFollowing.items.insert(user, at: 0)
        do {
            try await service.followUser(user)
        } catch {
            usersImFollowing.items.removeAll { $0 == user }
            throw error
        }
    }
    
    func unfollowUser(_ user: User) async throws {
        guard usersImFollowing.items.contains(user) else {
            return // throw?
        }
        let indexToRemove = usersImFollowing.items.firstIndex(of: user)!
        usersImFollowing.items.remove(at: indexToRemove)
        do {
            try await service.unfollowUser(user)
        } catch {
            usersImFollowing.items.insert(user, at: indexToRemove)
            throw error
        }
    }
        
    func pageOfUsers(_ pageURL: String) async throws -> Page<User> {
        try await service.pageOfItems(for: pageURL)
    }
}

// MARK: - Helpers
extension UserStore {
    func isUserFollowed(_ user: User) -> Bool {
        usersImFollowing.items.map(\.id).contains(user.id)
    }
}
