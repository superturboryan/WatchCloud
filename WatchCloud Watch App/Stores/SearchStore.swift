//
//  SearchStore.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-21.
//

import Foundation
import SoundCloud

final class SearchStore: ObservableObject {
    
    @Published public var searchHistory: [SearchEntry] = []
    
    private let service: SoundCloudAPI
    private let searchHistoryDAO: any DAO<[SearchEntry]>
    private let searchHistoryCapacity: Int
    
    init(
        _ service: SoundCloudAPI,
        _ searchHistoryDAO: any DAO<[SearchEntry]> = UserDefaultsDAO<[SearchEntry]>("SearchHistory"),
        searchHistoryCapacity: Int = 5
    ) {
        self.service = service
        self.searchHistoryDAO = searchHistoryDAO
        self.searchHistoryCapacity = searchHistoryCapacity
    }
}

// MARK: - Searching 🕵️
extension SearchStore {
    func searchForTracks(_ query: String, _ limit: Int = 20) async throws -> Page<Track> {
        try await addToSearchHistory(SearchEntry(.tracks, query))
        return try await service.searchTracks(query, limit)
    }
    
    func searchForUsers(_ query: String, _ limit: Int = 20) async throws -> Page<User> {
        try await addToSearchHistory(SearchEntry(.artists, query))
        return try await service.searchUsers(query, limit)
    }
    
    func searchForPlaylists(_ query: String, _ limit: Int = 20) async throws -> Page<Playlist> {
        try await addToSearchHistory(SearchEntry(.playlists, query))
        return try await service.searchPlaylists(query, limit)
    }
}

// MARK: - Search History 🔍
extension SearchStore {
    private func addToSearchHistory(_ entry: SearchEntry) async throws {
        AnalyticsManager.shared.log(.search(type: entry.type.rawValue))
        if let existingIndex = searchHistory.firstIndex(of: entry) {
            searchHistory.remove(at: existingIndex)
        } else if searchHistory.count == searchHistoryCapacity {
            searchHistory.removeLast() // removeLast() is safe here since we check count
        }
        searchHistory.insert(entry, at: 0)
        try searchHistoryDAO.save(searchHistory)
    }
    
    func load() {
        if let savedHistory = try? searchHistoryDAO.get() {
            searchHistory = savedHistory
        }
    }
    
    func reset() {
        searchHistory.removeAll()
        try? searchHistoryDAO.delete()
    }
}
