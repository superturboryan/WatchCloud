//
//  SearchView.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-04.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        VStack {
            searchCell("Tracks", "music.note")
            searchCell("Artists", "person.crop.circle.fill")
            searchCell("Playlists", "music.note.list")
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
    }
    
    func searchCell(_ title: String, _ icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Color.scOrange)
            Text(verbatim: title)
                .fullWidth(.leading)
        }
        .fontDesign(.rounded)
        .padding(10)
        .background(.secondary.opacity(0.2))
        .cornerRadius(10)
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
}
