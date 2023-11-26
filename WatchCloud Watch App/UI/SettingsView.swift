//
//  SettingsView.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-09-04.
//

import SoundCloud
import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var audioStore: AudioStore
    
    @State var showDeleteAllAlert = false
    
    private let downloadsColor = Color.scOrange
    private let otherAppsColor = Color.blue
    private let availableSpaceColor = Color.green
    
    var body: some View {
        List {
            Section(
                footer: Text("Displays a QR code in place of song artwork when watch is dimmed")
            ) {
                Toggle(isOn: Config.$showQRWhenWatchIsDimmed) {
                    VStack {
                        Text(String(localized: "Show QR code", comment: "Toggle label"))
                    }
                }
            }
            
            if !audioStore.downloadedTracks.isEmpty {
                Section(
                    header: Text("Downloads")
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(audioStore.downloadedTracks.count) tracks")
                            Text("(\(audioStore.downloadedTracksFileSize()) MB)").foregroundStyle(.secondary)
                        }
                        
                        Button("Delete all", role: .destructive) {
                            showDeleteAllAlert = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .listRowBackground(Color.clear)
                }
            }
        }
        .alert("Are you sure you want delete all downloads?", isPresented: $showDeleteAllAlert) {
            Button("Logout", role: .destructive) { try? audioStore.removeAllDownloads() }
            Button(String(localized: "Cancel", comment: "Verb"), role: .cancel) {}
        }
        .navigationBarTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(AudioStore(testSC))
    }
}
