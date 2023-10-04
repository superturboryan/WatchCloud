//
//  SearchView.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-04.
//

import SwiftUI

struct SearchView: View {
    
    @State var searchText = ""
    @State var searchType: SearchType = .tracks
    
    @FocusState var isSearchFocused: Bool
    @Namespace var search
    
    var body: some View {
        ScrollView {
            VStack {
                TextField("Search for \(searchType.rawValue)", text: $searchText)
                    .focused($isSearchFocused)
                    .onSubmit {
                        print("Searching for \(searchText)")
                    }
                GeometryReader { geo in
                    HStack {
                        searchCell(.tracks, width: (geo.size.width - 10) / 3)
                        searchCell(.playlists, width: (geo.size.width - 10) / 3)
                        searchCell(.users, width: (geo.size.width - 10) / 3)
                    }
                    .fullWidth()
                }
                .aspectRatio(contentMode: .fit)
            }
            .fullWidthAndHeight()
        }
        .focusScope(search)
        .animation(.default, value: searchType)
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func searchCell(_ type: SearchType, width: CGFloat) -> some View {
        VStack(spacing: 4) {
            Image(systemName: type.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
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
        .fontDesign(.rounded)
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
        case tracks, playlists, users
    
        var icon: String {
            switch self {
            case .tracks: return "music.note"
            case .playlists: return "music.note.list"
            case .users: return "person.crop.circle.fill"
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
}
