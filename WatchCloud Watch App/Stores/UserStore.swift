//
//  UserStore.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-18.
//

import Foundation
import SoundCloud

final class UserStore: ObservableObject {
    
    @Published public private(set) var isLoggedIn: Bool = true
    @Published public var myUser: User? = nil
    @Published public var usersImFollowing: Page<User>? = nil
    
    // MARK: - Dependencies
    private let userPersistenceService = UserDefaultsService<User>("\(User.self)")
    private let service: SoundCloudService
    init(_ service: SoundCloudService) {
        self.service = service
    }
}

// MARK: - Auth
extension UserStore {
    func login() async throws {
        do {
            try await service.login()
            isLoggedIn = true
        } catch {
            isLoggedIn = false
            throw error
        }
    }
    
    func logout() {
        service.logout()
        isLoggedIn = false
        userPersistenceService.delete()
    }
}

extension UserStore {
    func loadMyProfile() async throws {
        if let savedUser = userPersistenceService.get() {
            myUser = savedUser
        } else {
            let loadedUser = try await service.getMyUser()
            myUser = loadedUser
            userPersistenceService.save(loadedUser)
        }
    }
    
    func loadUsersImFollowing() async throws {
        if usersImFollowing == nil {
            let response = try await service.getUsersImFollowing()
            usersImFollowing = response
        } else if let nextPageUrl = usersImFollowing?.nextPage {
            let nextPage: Page<User> = try await pageOfUsers(nextPageUrl)
            usersImFollowing?.update(with: nextPage)
        }
    }
    
    func followUser(_ user: User) async throws {
        try await service.followUser(user)
        if var usersImFollowing, !usersImFollowing.items.contains(user) {
            usersImFollowing.items.insert(user, at: 0)
        }
    }
    
    func unfollowUser(_ user: User) async throws {
        try await service.unfollowUser(user)
        usersImFollowing?.items.removeAll(where: { $0 == user })
    }
    
    func searchForUsers(_ query: String) async throws -> Page<User> {
        try await service.searchUsers(query)
    }
    
    func pageOfUsers(_ pageURL: String) async throws -> Page<User> {
        try await service.pageOfItems(for: pageURL)
    }
}
