//
//  SCAudioPlayer.swift
//  SC Watch
//
//  Created by Ryan Forsyth on 2023-08-11.
//

import AVFoundation
import Combine
import MediaPlayer
import SoundCloud
import SwiftUI

enum PlaybackSpeed: Float, CaseIterable {
    case ThreeQuarters = 0.75
    case One = 1.0
    case OneAndAQuarter = 1.25
    case OnePointFive = 1.5
    case OneAndThreeQuarters = 1.75
    case Double = 2.0
}

@MainActor
final class SCAudioPlayer: ObservableObject {
    
    private weak var sc: SoundCloud!
    
    @Published var isPlaying = false // Should be private(set)
    @Published private(set) var isLoading = false
    @Published var progress: TimeInterval = 0.0 {
        didSet {
            if shouldSeek, let nowPlaying = sc.loadedTrack {
                let time = CMTime(
                    seconds: progress,
                    preferredTimescale: CMTimeScale(nowPlaying.durationInSeconds / 30)
                )
                player.seek(to: time)
                updateNowPlayingInfo(with: time)
            }
        }
    }
    @Published var playbackSpeed: PlaybackSpeed = .One
    
    let systemVolumePublisher = AVAudioSession.sharedInstance().publisher(for: \.outputVolume).eraseToAnyPublisher()
    
    private var shouldSeek = true
    private var isPlayerLoaded = false
    
    private let player = AVPlayer()
    private let audioSession = AVAudioSession.sharedInstance()
    private let decoder = JSONDecoder()
    private var subscriptions = Set<AnyCancellable>()
    
    
    
    init(_ sc: SoundCloud) {
        self.sc = sc
        setupDeviceMediaControls()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setupPlayer() {
        // TODO: Handle errors
        try? audioSession.setCategory(
            .playback,
            mode: .default,
            policy: .longFormAudio
        )
        try? audioSession.setActive(true)
        
        player.addPeriodicTimeObserver(forInterval: .oneSecond, queue: .main) { [weak self] time in
            self?.shouldSeek = false
            self?.progress = time.seconds
            self?.shouldSeek = true
        }
        player.publisher(for: \.timeControlStatus)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] status in
            self?.isPlaying = status == .playing || status == .waitingToPlayAtSpecifiedRate
            self?.isLoading = status == .waitingToPlayAtSpecifiedRate
            if self?.sc.loadedTrack != nil {
                self?.updateNowPlayingInfo()
            }
        }
        .store(in: &subscriptions)
    }
}

// MARK: - Play audio
extension SCAudioPlayer {
    private func loadTrack(_ track: Track) async throws {
        if !isPlayerLoaded {
            setupPlayer()
            isPlayerLoaded = true
        }
        
        //TODO: Handle error with do-catch
        let header = try await sc.authHeader
        let avUrlAsset = AVURLAsset(
            url: URL(string: track.playbackUrl!)!,
            options: ["AVURLAssetHTTPHeaderFieldsKey" : header]
        )
        let avItem = AVPlayerItem(asset: avUrlAsset)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.skipToNextTrack),
            name: Notification.Name.AVPlayerItemDidPlayToEndTime,
            object: avItem
        )
        
        // Set AVAudioPlayer item
        player.replaceCurrentItem(with: avItem)
        // Set loaded track in SC
        sc.loadedTrack = track
        progress = 0
    }
    
    func loadAndPlayTrack(_ track: Track) {
        showBluetoothOptionsIfBluetoothAudioOutputNotDetected()
        print("🎧 Load and play new track: \(track.title)")
        Task { [weak self] in
            try await self?.loadTrack(track)
            self?.player.play()
            self?.player.rate = self?.playbackSpeed.rawValue ?? 1
        }
    }
    
    func togglePlayback() {
        if let queue = sc.nowPlayingQueue, !queue.isEmpty, sc.loadedTrack == nil {
            //What was this case for again?
            loadAndPlayTrack(queue.first!)
            return
        }
        
        if isPlaying {
            player.pause()
        } else {
            player.play()
            player.rate = playbackSpeed.rawValue
        }
        print(isPlaying ? "🎧 Resumed" : "🎧 Paused")
    }
    
    func continuePlayback() {
        player.play()
        player.rate = playbackSpeed.rawValue
    }
    
    func pausePlayback() {
        player.pause()
    }
    
    @objc // Called by AVPlayerItemDidPlayToEndTime Notification
    func skipToNextTrack() {
        guard let nextTrack = sc.nextTrackInNowPlayingQueue
        else { return }
        
        if isPlaying {
            loadAndPlayTrack(nextTrack)
        } else {
            // Only load next track, don't start playing
            Task { [weak self] in try await self?.loadTrack(nextTrack) }
        }
    }
    
    func skipToPreviousTrack() {
        let skipToPreviousTrackThreshold: Double = 3
        let isBeginningOfTrack = progress < skipToPreviousTrackThreshold
        let isBeginningOfQueue = sc.loadedTrackNowPlayingQueueIndex == 0
        let shouldSkipToPreviousTrack = isBeginningOfTrack && !isBeginningOfQueue
        
        if shouldSkipToPreviousTrack, let previousTrack = sc.previousTrackInNowPlayingQueue {
            if isPlaying {
                loadAndPlayTrack(previousTrack)
            } else {
                // Only load previous track, don't start playing
                Task { [weak self] in try await self?.loadTrack(previousTrack) }
            }
        } else { // Just go to beginning
            progress = 0
        }
    }
    
    func cyclePlaybackSpeed() {
        playbackSpeed = playbackSpeed.next()
        if isPlaying {
            player.rate = playbackSpeed.rawValue
        }
    }
    
    private func showBluetoothOptionsIfBluetoothAudioOutputNotDetected() {
        audioSession.activate(options: []) { [weak self] success, error in
            // TODO: Handle error, show alert?
            if let error { print("Session activation error: \(error.localizedDescription)") }
            if success { DispatchQueue.main.async { self?.player.play() } }
        }
    }
}

// MARK: - MPNowPlayingInfoCenter
extension SCAudioPlayer {
    
    private func setupDeviceMediaControls() {
        let center = MPRemoteCommandCenter.shared()
        
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayback()
            return .success
        }
        
        center.playCommand.addTarget { [weak self] _ in
            self?.togglePlayback()
            return .success
        }

        center.pauseCommand.addTarget { [weak self] _ in
            self?.togglePlayback()
            return .success
        }

        center.nextTrackCommand.addTarget { [weak self] _ in
            guard
                let queue = self?.sc.nowPlayingQueue, // Queue exists
                let nowPlayingQueueIndex = self?.sc.loadedTrackNowPlayingQueueIndex,
                nowPlayingQueueIndex < queue.count - 1 // Not at end of queue
            else {  return .commandFailed }
            
            self?.skipToNextTrack()
            return .success
        }

        center.previousTrackCommand.addTarget { [weak self] _ in
            self?.skipToPreviousTrack()
            return .success
        }
        
        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self?.progress = event.positionTime
            return .success
        }
    }
    
    private func updateNowPlayingInfo(with time: CMTime? = nil) {
        let center = MPNowPlayingInfoCenter.default()
        guard let loadedTrack = sc.loadedTrack else {
            center.nowPlayingInfo = nil
            return
        }
        
        var info = center.nowPlayingInfo
        let currentID = info?[MPMediaItemPropertyPersistentID] as? Int
        let currentTime = (time ?? player.currentTime()).seconds
        
        if currentID == loadedTrack.id {
            info![MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        }
        else {
            info = [
                MPMediaItemPropertyPersistentID: loadedTrack.id,
                MPMediaItemPropertyTitle: loadedTrack.title,
                MPMediaItemPropertyArtist: loadedTrack.user.username,
                MPMediaItemPropertyAssetURL: loadedTrack.permalinkUrl,
                MPMediaItemPropertyPlaybackDuration: loadedTrack.durationInSeconds,
                MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime
            ]
            
            let url = loadedTrack.artworkUrl ?? loadedTrack.user.avatarUrl 
            Task { [weak self] in
                let artwork = await self?.fetchArtwork(url)
                info![MPMediaItemPropertyArtwork] = artwork
                center.nowPlayingInfo = info
            }
        }
        
        center.nowPlayingInfo = info
    }
    
    private func fetchArtwork(_ url: String) async -> MPMediaItemArtwork {
        let largerImageUrl = url.replacingOccurrences(of: "large.jpg", with: "t500x500.jpg")
        guard
            let url = URL(string: largerImageUrl),
            // TODO: Handle response
            let (data, _) = try? await URLSession.shared.data(for: URLRequest(url: url))
        //TODO: Check response
        else {
            let fallbackImage = UIImage(systemName: "xmark.icloud.fill")!
            return MPMediaItemArtwork(boundsSize: fallbackImage.size) { _ in fallbackImage }
        }
        let image = UIImage(data: data)!
        return MPMediaItemArtwork(boundsSize: image.size) { _ in image }
    }
}

extension CMTime {
    static var oneSecond: CMTime { .init(value: 1, timescale: 1) }
}
