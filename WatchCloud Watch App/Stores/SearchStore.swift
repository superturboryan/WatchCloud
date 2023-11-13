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
        guard !query.isEmpty else {
            throw Error.emptyQuery
        }
        try await addToSearchHistory(SearchEntry(.tracks, query))
        do { return try await service.searchTracks(query, limit) }
        catch { throw Error.searching }
    }
    
    func searchForUsers(_ query: String, _ limit: Int = 20) async throws -> Page<User> {
        guard !query.isEmpty else {
            throw Error.emptyQuery
        }
        try await addToSearchHistory(SearchEntry(.artists, query))
        do { return try await service.searchUsers(query, limit) }
        catch { throw Error.searching }
    }
    
    func searchForPlaylists(_ query: String, _ limit: Int = 20) async throws -> Page<Playlist> {
        guard !query.isEmpty else {
            throw Error.emptyQuery
        }
        try await addToSearchHistory(SearchEntry(.playlists, query))
        do { return try await service.searchPlaylists(query, limit) }
        catch { throw Error.searching }
    }
}

// MARK: - Search History 🔍
extension SearchStore {
    
    @MainActor
    private func addToSearchHistory(_ entry: SearchEntry) async throws {
        AnalyticsManager.shared.log(.search(type: entry.type.rawValue))
        if let existingIndex = searchHistory.firstIndex(of: entry) {
            searchHistory.remove(at: existingIndex)
        } else if searchHistory.count == searchHistoryCapacity {
            searchHistory.removeLast() // removeLast() is safe here since we check count
        }
        searchHistory.insert(entry, at: 0)
        do { try searchHistoryDAO.save(searchHistory) }
        catch { throw Error.updatingSearchHistory }
    }
    
    @MainActor
    func load() {
        if let savedHistory = try? searchHistoryDAO.get() {
            searchHistory = savedHistory
        }
    }
    
    @MainActor
    func reset() {
        searchHistory.removeAll()
        try? searchHistoryDAO.delete()
    }
}

extension SearchStore {
    enum Error: LocalizedError {
        case emptyQuery
        case updatingSearchHistory
        case searching
    }
}
