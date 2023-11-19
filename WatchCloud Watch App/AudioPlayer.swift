//
//  SCAudioPlayer.swift
//  SC Watch
//
//  Created by Ryan Forsyth on 2023-08-11.
//

import AVFoundation
import Combine
import MediaPlayer
import OSLog
import SoundCloud
import SwiftUI

@MainActor
final class AudioPlayer: ObservableObject {
    
    @Published var isPlaying = false // Should be private(set)
    @Published private(set) var isLoading = false
    
    /// Describes how many seconds the player's current item has been playing for.
    ///
    /// Updating this property causes the player (`AVPlayer`) to seek to the selected value (in seconds) 
    /// and updates the info displayed by the device's "Now Playing".
    @Published var progress: TimeInterval = 0.0 { didSet { updatePlayerProgress() }}
    @Published var selectedPlaybackSpeed: PlaybackSpeed = .One
    
    private let player = AVPlayer()
    private var isPlayerLoaded = false
    
    private var shouldSeek = true
    private var seekTimer: Timer? = nil
    private var seekAmount: TimeInterval { (player.currentItem?.duration.seconds ?? 0) / 30.0 }
    
    private let remoteCommands = MPRemoteCommandCenter.shared()
    private let nowPlaying = MPNowPlayingInfoCenter.default()
    private let audioSession = AVAudioSession.sharedInstance()
    
    private let decoder = JSONDecoder()
    private var subscriptions = Set<AnyCancellable>()
    
    private let audioStore: AudioStore
    private let authStore: AuthStore
    init(_ audioStore: AudioStore, _ authStore: AuthStore) {
        self.audioStore = audioStore
        self.authStore = authStore
        setupDeviceMediaControls()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupPlayer() {
        try? audioSession.setCategory(
            .playback,
            mode: .default,
            policy: .longFormAudio
        )
        try? audioSession.setActive(true)
        
        let oneSecond = CMTime(value: 1, timescale: 1)
        player.addPeriodicTimeObserver(forInterval: oneSecond, queue: .main) { [weak self] time in
            DispatchQueue.main.async { [weak self] in
                self?.shouldSeek = false
                self?.progress = time.seconds
                self?.shouldSeek = true
            }
        }
        player.publisher(for: \.timeControlStatus)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] status in
            self?.isPlaying = status == .playing || status == .waitingToPlayAtSpecifiedRate
            self?.isLoading = status == .waitingToPlayAtSpecifiedRate
            if self?.audioStore.loadedTrack != nil {
                self?.updateNowPlayingInfo()
            }
        }
        .store(in: &subscriptions)
    }
    
    private func updatePlayerProgress() {
        guard shouldSeek, let nowPlaying = audioStore.loadedTrack else {
            return
        }
        let time = CMTime(
            seconds: progress,
            preferredTimescale: CMTimeScale(nowPlaying.durationInSeconds / 30)
        )
        player.seek(to: time)
        updateNowPlayingInfo(with: time)
    }
}

// MARK: - Play audio
extension AudioPlayer {
    private func loadTrack(_ track: Track) async throws {
        if !isPlayerLoaded {
            setupPlayer()
            isPlayerLoaded = true
        }
        let avUrlAsset = AVURLAsset(
            url: URL(string: track.playbackUrl!)!, // ⚠️ Check if playback url exists!
            options: ["AVURLAssetHTTPHeaderFieldsKey" : try await authStore.authHeader]
        )
        let avItem = AVPlayerItem(asset: avUrlAsset)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.nextTrackCommand),
            name: Notification.Name.AVPlayerItemDidPlayToEndTime,
            object: avItem
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.player.replaceCurrentItem(with: avItem)
            self?.audioStore.loadedTrack = track
            self?.progress = 0
        }
    }
    
    func loadAndPlayTrack(_ track: Track) {
        showBluetoothOptionsIfBluetoothAudioOutputNotDetected()
        Logger.audioPlayer.info("🎧 Load and play new track: \(track.title)")
        Task { [weak self] in
            try await self?.loadTrack(track)
            DispatchQueue.main.async { [weak self] in
                self?.player.play()
                self?.player.rate = self?.selectedPlaybackSpeed.rawValue ?? 1
            }
        }
    }
    
    func togglePlayback() {
        if let queue = audioStore.nowPlayingQueue, !queue.isEmpty, audioStore.loadedTrack == nil {
            //What was this case for again?
            loadAndPlayTrack(queue.first!)
            return
        }
        
        if isPlaying {
            player.pause()
        } else {
            player.play()
            player.rate = selectedPlaybackSpeed.rawValue
        }
    }
    
    func continuePlayback() {
        player.play()
        player.rate = selectedPlaybackSpeed.rawValue
    }
    
    func pausePlayback() {
        player.pause()
    }
    
    func stop() {
        player.pause()
        player.replaceCurrentItem(with: nil)
    }
    
    @objc // Also called by AVPlayerItemDidPlayToEndTime Notification
    func nextTrackCommand() {
        guard let nextTrack = audioStore.nextTrackInNowPlayingQueue
        else { return }
        
        if isPlaying {
            loadAndPlayTrack(nextTrack)
        } else { // Only load next track, don't start playing
            Task { [weak self] in try await self?.loadTrack(nextTrack) }
        }
    }
    
    func previousTrackCommand() {
        let skipToPreviousTrackSecondsThreshold: Double = 3
        let isBeginningOfTrack = progress < skipToPreviousTrackSecondsThreshold
        let isBeginningOfQueue = audioStore.loadedTrackPlaylistIndex == 0
        let shouldSkipToPreviousTrack = isBeginningOfTrack && !isBeginningOfQueue
        
        if shouldSkipToPreviousTrack, let previousTrack = audioStore.previousTrackInNowPlayingQueue {
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
    
    func seekForwardCommand() {
        guard let duration = player.currentItem?.duration.seconds else {
            return
        }
        if progress + seekAmount > duration {
            progress = duration
        } else {
            progress += seekAmount
        }
    }
    
    func seekBackwardCommand() {
        if progress == 0 {
            return
        } else if progress - seekAmount < 0 {
            progress = 0
        } else {
            progress -= seekAmount
        }
    }
    
    func beginSeeking(_ direction: SeekDirection) {
        seekTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            direction.isBackward ?
                self?.seekBackwardCommand() :
                self?.seekForwardCommand()
        }
    }
    
    func endSeeking() {
        seekTimer?.invalidate()
    }
    
    func cyclePlaybackSpeed() {
        selectedPlaybackSpeed = selectedPlaybackSpeed.next()
        if isPlaying {
            player.rate = selectedPlaybackSpeed.rawValue
        }
    }
    
    private func showBluetoothOptionsIfBluetoothAudioOutputNotDetected() {
        audioSession.activate(options: []) { [weak self] success, error in
            if let error {
                Logger.audioPlayer.error("Session activation error: \(error.localizedDescription)")
            }
            if success {
                DispatchQueue.main.async { self?.player.play() }
            }
        }
    }
}

// MARK: - MPNowPlayingInfoCenter
extension AudioPlayer {
    
    private func setupDeviceMediaControls() {
        remoteCommands.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayback()
            return .success
        }
        remoteCommands.playCommand.addTarget { [weak self] _ in
            self?.continuePlayback()
            return .success
        }
        remoteCommands.pauseCommand.addTarget { [weak self] _ in
            self?.pausePlayback()
            return .success
        }
        remoteCommands.nextTrackCommand.addTarget { [weak self] _ in
            guard
                let queue = self?.audioStore.nowPlayingQueue, // Queue exists
                let nowPlayingQueueIndex = self?.audioStore.loadedTrackPlaylistIndex,
                nowPlayingQueueIndex < queue.count - 1 // Not at end of queue
            else {  return .commandFailed }
            
            self?.nextTrackCommand()
            return .success
        }
        remoteCommands.previousTrackCommand.addTarget { [weak self] _ in
            self?.previousTrackCommand()
            return .success
        }
        remoteCommands.seekForwardCommand.addTarget { [weak self] event in
            guard let event = event as? MPSeekCommandEvent else { 
                return .commandFailed
            }
            
            guard // Not at end of track
                let duration = self?.player.currentItem?.duration,
                let progress = self?.progress,
                progress < duration.seconds
            else { return .commandFailed }
            
            switch event.type {
            case .beginSeeking: self?.beginSeeking(.forward)
            case .endSeeking: self?.endSeeking()
            @unknown default: Logger.audioPlayer.warning("Unknown seek event type")
            }
            
            return .success
        }
        remoteCommands.seekBackwardCommand.addTarget { [weak self] event in
            guard let event = event as? MPSeekCommandEvent else {
                return .commandFailed
            }
            
            guard // Not at beginning of track
                let progress = self?.progress, progress > 0
            else { return .commandFailed }
    
            switch event.type {
            case .beginSeeking: self?.beginSeeking(.backward)
            case .endSeeking: self?.endSeeking()
            @unknown default: Logger.audioPlayer.warning("Unknown seek event type")
            }
            
            return .success
        }
        remoteCommands.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self?.progress = event.positionTime
            return .success
        }
    }
    
    private func updateNowPlayingInfo(with time: CMTime? = nil) {
        guard let loadedTrack = audioStore.loadedTrack else {
            nowPlaying.nowPlayingInfo = nil
            return
        }
        
        var info = nowPlaying.nowPlayingInfo
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
                guard let artwork = await self?.fetchArtwork(url) else {
                    return
                }
                self?.nowPlaying.nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
            }
        }
        
        nowPlaying.nowPlayingInfo = info
    }
    
    private func fetchArtwork(_ url: String) async -> MPMediaItemArtwork {
        let largerImageUrl = url.replacingOccurrences(of: "large.jpg", with: "t500x500.jpg")
        guard
            let url = URL(string: largerImageUrl),
            // Error, response not handled
            let (data, _) = try? await URLSession.shared.data(for: URLRequest(url: url))
        else {
            let fallbackImage = UIImage(systemName: "xmark.icloud.fill")!
            return MPMediaItemArtwork(boundsSize: fallbackImage.size) { _ in fallbackImage }
        }
        let image = UIImage(data: data)!
        return MPMediaItemArtwork(boundsSize: image.size) { _ in image }
    }
}

extension AudioPlayer {
    enum PlaybackSpeed: Float, CaseIterable {
        case ThreeQuarters = 0.75
        case One = 1.0
        case OneAndAQuarter = 1.25
        case OnePointFive = 1.5
        case OneAndThreeQuarters = 1.75
        case Double = 2.0
    }
    
    enum SeekDirection {
        case backward
        case forward
        
        var isBackward: Bool { self == .backward }
    }
}

extension AudioPlayer {
    static let systemVolumePublisher = AVAudioSession.sharedInstance().publisher(for: \.outputVolume).eraseToAnyPublisher()
}

@MainActor
let testAudioPlayer = AudioPlayer(AudioStore(testSC), AuthStore(testSC))
