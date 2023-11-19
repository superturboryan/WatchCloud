//
//  SearchView.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-04.
//

import SoundCloud
import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject var audioStore: AudioStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var searchStore: SearchStore
    
    @State var showSearchResults = false
    @State var query = ""
    @State var searchType: SearchType = .tracks
    
    @State var trackResults: Page<Track>? = nil
    @State var playlistResults: Page<Playlist>? = nil
    @State var artistResults: Page<User>? = nil
    
    var body: some View {
        ScrollView {
            VStack {
                searchTextField
                searchOptionButtons
                if !searchStore.searchHistory.isEmpty {
                    searchHistoryList
                }
            }
            .animation(.default, value: searchStore.searchHistory)
            .fullWidthAndHeight()
            .toolbar {
                toolbarSearchButton
            }
            .navigationDestination(isPresented: $showSearchResults) {
                searchResultsView
            }
            .padding(.top, -4)
            .fontDesign(.rounded)
            .animation(.default, value: searchType)
        }
    }
    
    private var searchTextField: some View {
        TextField(
            String(localized: "Search for \(searchType.localized)", comment: "Prompt"),
            text: $query
        )
        .autocorrectionDisabled()
        .submitLabel(.search)
        .onSubmit { performSearch(with: query) }
    }
    
    @ViewBuilder
    private var searchOptionButtons: some View {
        let width = (Device.screenSize.width - 18) / 3
        HStack {
            searchCell(.tracks, width: width)
            searchCell(.playlists, width: width)
            searchCell(.artists, width: width)
        }
    }
    
    private var toolbarSearchButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                performSearch(with: query)
            } label: {
                Image(systemName: "magnifyingglass.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(LinearGradient.scOrange(.vertical))
            }
            .disabled(query.isEmpty)
            .buttonStyle(.plain)
        }
    }
    
    private func performSearch(with query: String) {
        guard !query.isEmpty else { return }
        Task {
            switch searchType {
            case .tracks: trackResults = try await searchStore.searchForTracks(query, 100)
            case .playlists: playlistResults = try await searchStore.searchForPlaylists(query)
            case .artists: artistResults = try await searchStore.searchForUsers(query)
            }
            showSearchResults = true
        }
    }
    
    @ViewBuilder
    private var searchResultsView: some View {
        switch searchType {
        case .tracks:
            if var playlist = trackResults?.playlist(id: 0, title: query, user: userStore.myUser!) {
                PlaylistView(
                    playlist: Binding(get: {
                        playlist
                    }, set: { updated in
                        playlist = updated
                    }),
                    showSummary: false,
                    showShuffleButton: false
                )
            }
        case .playlists:
            if let results = Binding($playlistResults) {
                PlaylistListView(
                    playlists: results.items,
                    canLoadMore: .constant(results.wrappedValue.hasNextPage),
                    title: "\"\(query)\""
                ) {
                    Task {
                        if let nextPageURL = results.wrappedValue.nextPageURL,
                           let nextPage: Page<Playlist> = try? await audioStore.pageOfPlaylists(nextPageURL) {
                            playlistResults?.update(with: nextPage)
                        }
                    }
                }
            }
        case .artists:
            if let results = Binding($artistResults) {
                UserListView(
                    users: results.items,
                    canLoadMore: .constant(results.wrappedValue.hasNextPage),
                    title: "\"\(query)\"",
                    sortedAlphabetically: false
                ) {
                    Task {
                        if let nextPageURL = results.wrappedValue.nextPageURL,
                           let nextPage: Page<User> = try? await userStore.pageOfUsers(nextPageURL) {
                            artistResults?.update(with: nextPage)
                        }
                    }
                }
            }
        }
    }
    
    private func searchCell(_ type: SearchType, width: CGFloat) -> some View {
        VStack(spacing: 4) {
            Image(systemName: type.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(LinearGradient.scOrange(.vertical))
            
            Text(verbatim: type.localized.capitalized)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(searchType == type ? .primary : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 6)
                .frame(width: width, height: 18)
        }
        .padding(.vertical, 8)
        .background(searchType == type ? Color.scOrange.opacity(0.3) : .secondary.opacity(0.2))
        .cornerRadius(8)
        .onTapGesture {
            searchType = type
        }
    }
    
    private var searchHistoryList: some View {
        LazyVStack {
            Section(header: sectionHeaderView(String(localized: "History"))) {
                ForEach(searchStore.searchHistory) { entry in
                    searchHistoryCell(entry).onTapGesture {
                        query = entry.query
                        searchType = entry.type
                        performSearch(with: query)
                    }
                }
                Button(String(localized: "Clear History"), role: .destructive) {
                    searchStore.reset()
                    query = ""
                }
            }
        }
    }
    
    private func searchHistoryCell(_ entry: SearchEntry) -> some View {
        HStack(spacing: 10) {
            Image(systemName: entry.type.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .foregroundStyle(LinearGradient.scOrange(.vertical))
            Text(verbatim: entry.query)
                .fontWeight(.medium)
                .fullWidth(.leading)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .background(.secondary.opacity(0.2))
        .cornerRadius(10)
    }
}

enum SearchType: String, Codable {
    case tracks, playlists, artists
}

extension SearchType {
    var localized: String {
        switch self {
        case .tracks: String(localized: "tracks", comment: "Plural noun")
        case .playlists: String(localized: "playlists", comment: "Plural noun")
        case .artists: String(localized: "artists", comment: "Plural noun")
        }
    }
    
    var icon: String {
        switch self {
        case .tracks: "music.note"
        case .playlists: "music.note.list"
        case .artists: "person.crop.circle.fill"
        }
    }
}


#Preview {
    NavigationStack {
        SearchView()
            .environmentObject(AudioStore(testSC))
            .environmentObject(UserStore(testSC))
            .environmentObject({ () -> SearchStore in
                let store = SearchStore(testSC)
                store.searchHistory = [
                    SearchEntry(.artists, "Rinse FM Rinse FM Rinse FM"),
                    SearchEntry(.playlists, "Jungle"),
                    SearchEntry(.tracks, "Drake"),
                ]
                return store
            }())
    }
}
