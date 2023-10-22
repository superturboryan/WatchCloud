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
    
    private let searchHistoryDAO = UserDefaultsDAO<[SearchEntry]>("SearchHistory")
    private let searchHistoryCapacity: Int
    private let service: SoundCloud
    init(_ service: SoundCloud, searchHistoryCapacity: Int = 5) {
        self.service = service
        self.searchHistoryCapacity = searchHistoryCapacity
    }
}

// MARK: - Searching 🕵️
extension SearchStore {
    func searchForTracks(_ query: String, _ limit: Int = 20) async throws -> Page<Track> {
        addToSearchHistory(SearchEntry(.tracks, query))
        return try await service.searchTracks(query, limit)
    }
    
    func searchForUsers(_ query: String) async throws -> Page<User> {
        addToSearchHistory(SearchEntry(.artists, query))
        return try await service.searchUsers(query)
    }
    
    func searchForPlaylists(_ query: String) async throws -> Page<Playlist> {
        addToSearchHistory(SearchEntry(.playlists, query))
        return try await service.searchPlaylists(query)
    }
}

// MARK: - Search History 🔍
extension SearchStore {
    func addToSearchHistory(_ entry: SearchEntry) {
        AnalyticsManager.shared.log(.search(type: entry.type.rawValue))
        Task {
            if let existingIndex = searchHistory.firstIndex(of: entry) {
                _ = await MainActor.run { searchHistory.remove(at: existingIndex) }
            } else if searchHistory.count == searchHistoryCapacity {
                _ = await MainActor.run { searchHistory.removeLast() } // removeLast() is safe here since we check count
            }
            await MainActor.run { searchHistory.insert(entry, at: 0) }
            try? searchHistoryDAO.save(searchHistory)
        }
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
