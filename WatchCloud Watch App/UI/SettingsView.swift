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
            appInfoSection
        }
        .alert("Are you sure you want to remove all downloads?", isPresented: $showDeleteAllAlert) {
            Button("Remove All", role: .destructive) { try? audioStore.removeAllDownloads() }
            Button(String(localized: "Cancel", comment: "Verb"), role: .cancel) {}

        }
        .fontDesign(.rounded)
        .navigationBarTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var playbackSection: some View {
        Section(
            footer: Text("Display a QR code in place of artwork when watch is dimmed")
        ) {
            Toggle(isOn: Config.$showQRWhenWatchIsDimmed) {
                Text(String(localized: "Show QR Code", comment: "Toggle label"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
    }
    
    @ViewBuilder
    private var downloadsSection: some View {
        if Config.isDownloadingEnabled(for: userStore.myUser?.id) {
            Section(
                header: Text("Downloads").padding(.bottom, 2)
            ) {
                Toggle(isOn: Config.$allowDownloadingUsingData, label: {
                    Text(String(localized: "Cellular Data", comment: "Toggle label"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                })
                
                HStack {
                    Text(String(localized: "%d Tracks", defaultValue: "\(audioStore.downloadedTracks.count) Tracks"))
                        .minimumScaleFactor(0.8)
                    Spacer(minLength: 10)
                    HStack {
                        Text(verbatim: audioStore.downloadedTracksFileSize.formattedFileSizeInMbOrGb)
                        Image(systemName: "applewatch")
                    }
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(.secondary)
                }
                .lineLimit(1)
                
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
    
    private var appInfoSection: some View {
        Section(
            header: Text("App").padding(.bottom, 2)
        ) {
            HStack {
                Text("Version")
                Spacer()
                Text(Config.appVersion)
                    .fontWeight(.medium)
            }
            
            PoweredBySCView()
                .fullWidth()
                .padding(.top, 6)
                .listRowBackground(Color.clear)
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
