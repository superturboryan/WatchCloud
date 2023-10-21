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
    @Published public var usersImFollowing: Page<User>? = nil
    @Published public var searchHistory: [(SearchType, String)] = []
    
    // MARK: - Dependencies
    private let myUserDAO = UserDefaultsDAO<User>("\(User.self)")
    private let searchHistoryDAO = UserDefaultsDAO<Data>("SearchHistory")
    private let service: SoundCloud
    init(_ service: SoundCloud) {
        self.service = service
    }
}

extension UserStore {
    func load() async throws {
        loadSearchHistory()
        try await loadMyProfile()
        try await loadUsersImFollowing()
    }
    
    func reset() {
        try? myUserDAO.delete()
        myUser = nil
        usersImFollowing = nil
        clearSearchHistory()
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
        usersImFollowing?.items.insert(user, at: 0)
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

// MARK: - Search History 🔍
extension UserStore {
    func addToSearchHistory(_ searchType: SearchType, _ query: String) {
        let capacity = 5
        if searchHistory.count == capacity {
            searchHistory.removeLast() // removeLast() is safe here since we check count
        }
        searchHistory.insert((searchType, query), at: 0)
        saveSearchHistory()
    }
    
    func saveSearchHistory() {
        if let data = try? JSONSerialization.data(withJSONObject: searchHistory, options: []) {
            try? searchHistoryDAO.save(data)
        }
    }
    
    func loadSearchHistory() {
        if let data = try? searchHistoryDAO.get(),
           let savedHistory = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [(SearchType, String)] {
            searchHistory = savedHistory
        }
    }
    
    func clearSearchHistory() {
        searchHistory.removeAll()
        try? searchHistoryDAO.delete()
    }
}
