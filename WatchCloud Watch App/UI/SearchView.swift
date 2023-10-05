//
//  SearchView.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-04.
//

import SoundCloud
import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject var sc: SoundCloud
    
    @State var showSearchResults = false
    @State var query = ""
    @State var searchType: SearchType = .tracks
    
    @State var trackResults: Page<Track>? = nil
    @State var playlistResults: Page<Playlist>? = nil
    @State var artistResults: Page<User>? = nil
    
    @FocusState var isSearchFocused: Bool
    @Namespace var search
    
    var body: some View {
        ScrollView {
            VStack {
                TextField("Search for \(searchType.rawValue)", text: $query)
                    .autocorrectionDisabled()
                    .focused($isSearchFocused)
                    .submitLabel(.search)
                    .onSubmit { performSearch(with: query) }
                searchOptionButtons
            }
            .fullWidthAndHeight()
        }
        .toolbar {
            searchButton
        }
        .navigationDestination(isPresented: $showSearchResults) {
            searchResultsView
        }
        .focusScope(search)
        .fontDesign(.rounded)
        .animation(.default, value: searchType)
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var searchOptionButtons: some View {
        GeometryReader { geo in
            HStack {
                searchCell(.tracks, width: (geo.size.width - 10) / 3)
                searchCell(.playlists, width: (geo.size.width - 10) / 3)
                searchCell(.artists, width: (geo.size.width - 10) / 3)
            }
            .fullWidth()
        }
        .aspectRatio(contentMode: .fit)
    }
    
    private var searchButton: some ToolbarContent {
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
        Task {
            switch searchType {
            case .tracks:
                trackResults = try await sc.searchTracks(query)
            case .playlists:
                playlistResults = try await sc.searchPlaylists(query)
            case .artists:
                artistResults = try await sc.searchUsers(query)
            }
            
            showSearchResults = true
        }
    }
    
    @ViewBuilder
    private var searchResultsView: some View {
        switch searchType {
        case .tracks:
            if let tracks = trackResults?.items {
                let playlist = Playlist(id: 0, user: sc.myUser!, title: query, tracks: tracks)
                PlaylistView(
                    playlist: .constant(playlist),
                    downloadedTracks: sc.downloadedTracks,
                    showHeader: false
                )
            }
        case .playlists:
            if let results = Binding($playlistResults) {
                #warning("Playlists are loaded from sc.loadedPlaylists.....")
                PlaylistListView(
                    playlists: results.items,
                    canLoadMore: .constant(results.wrappedValue.hasNextPage),
                    title: query
                ) {
                    Task {
                        if let nextPage = results.wrappedValue.nextPage,
                            let nextResult: Page<Playlist> = try? await sc.pageOfItems(for: nextPage) {
                            playlistResults?.update(with: nextResult)
                        }
                    }
                }
            }
        case .artists:
            if let results = Binding($artistResults) {
                UserListView(
                    users: results.items,
                    canLoadMore: .constant(results.wrappedValue.hasNextPage),
                    title: query
                ) {
                    Task {
                        if let nextPage = results.wrappedValue.nextPage, 
                            let nextResult: Page<User> = try? await sc.pageOfItems(for: nextPage) {
                            artistResults?.update(with: nextResult)
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
                
            Text(verbatim: type.rawValue.capitalized)
                .font(.footnote)
                .foregroundColor(searchType == type ? .primary : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 2)
                .frame(width: width, height: 18)
                
                
        }
        .fontWeight(searchType == type ? .medium : .regular)
        .padding(.vertical, 10)
        .background(searchType == type ? Color.scOrange.opacity(0.3) : .secondary.opacity(0.2))
        .cornerRadius(10)
        .onTapGesture {
            searchType = type
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isSearchFocused = true
            }
        }
    }
}

extension SearchView {
    enum SearchType: String {
        case tracks, playlists, artists
    
        var icon: String {
            switch self {
            case .tracks: return "music.note"
            case .playlists: return "music.note.list"
            case .artists: return "person.crop.circle.fill"
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchView()
            .environmentObject(testSC)
    }
}
