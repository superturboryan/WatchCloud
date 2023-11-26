//
//  SettingsView.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-09-04.
//

import SoundCloud
import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var audioStore: AudioStore
    
    @State var showDeleteAllAlert = false
    
    private let downloadsColor = Color.scOrange
    private let otherAppsColor = Color.blue
    private let availableSpaceColor = Color.green
    
    var body: some View {
        List {
            playbackSection
            downloadsSection
        }
        .alert("Are you sure you want to remove all downloads?", isPresented: $showDeleteAllAlert) {
            Button("Remove All", role: .destructive) { try? audioStore.removeAllDownloads() }
            Button(String(localized: "Cancel", comment: "Verb"), role: .cancel) {}

        }
        .navigationBarTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var playbackSection: some View {
        Section(
            footer: Text("Display a QR code in place of artwork when watch is dimmed")
        ) {
            Toggle(isOn: Config.$showQRWhenWatchIsDimmed) {
                Text(String(localized: "Show QR Code", comment: "Toggle label"))
            }
        }
    }
    
    @ViewBuilder
    private var downloadsSection: some View {
        if Config.isDownloadingEnabled(for: userStore.myUser?.id) {
            Section(
                header: Text("Downloads")
            ) {
                Toggle(isOn: Config.$allowDownloadingUsingData, label: {
                    Text(String(localized: "Use Cellular Data", comment: "Toggle label"))
                })
                
                HStack {
                    Text(String(localized: "%d Tracks", defaultValue: "\(audioStore.downloadedTracks.count) Tracks"))
                    Spacer()
                    Text(verbatim: audioStore.downloadedTracksFileSize.formattedFileSizeInMbOrGb)
                        .foregroundStyle(.secondary)
                }
                
                if !audioStore.downloadedTracks.isEmpty {
                    Button("Remove All", role: .destructive) {
                        showDeleteAllAlert = true
                    }
                    .buttonStyle(.bordered)
                    .listItemTint(.clear)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(AudioStore(testSC))
            .environmentObject(UserStore(testSC))
    }
}
