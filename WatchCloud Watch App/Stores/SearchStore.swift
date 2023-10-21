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
    private let service: SoundCloud
    init(_ service: SoundCloud) {
        self.service = service
    }
}

// MARK: - Searching 🕵️
extension SearchStore {
    func searchForTracks(_ query: String, _ limit: Int = 20) async throws -> Page<Track> {
        addToSearchHistory(.tracks, query)
        return try await service.searchTracks(query, limit)
    }
    
    func searchForUsers(_ query: String) async throws -> Page<User> {
        addToSearchHistory(.artists, query)
        return try await service.searchUsers(query)
    }
    
    func searchForPlaylists(_ query: String) async throws -> Page<Playlist> {
        addToSearchHistory(.playlists, query)
        return try await service.searchPlaylists(query)
    }
}

// MARK: - Search History 🔍
extension SearchStore {
    func addToSearchHistory(_ searchType: SearchType, _ query: String) {
        AnalyticsManager.shared.log(.search(type: searchType.rawValue))
        let capacity = 5
        Task { await MainActor.run {
            if let existingIndex = searchHistory.firstIndex(where: { $0.query == query }) {
                searchHistory.remove(at: existingIndex)
            } else if searchHistory.count == capacity {
                searchHistory.removeLast() // removeLast() is safe here since we check count
            }
            searchHistory.insert(SearchEntry(searchType, query), at: 0)
            try? searchHistoryDAO.save(searchHistory)
        }}
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
