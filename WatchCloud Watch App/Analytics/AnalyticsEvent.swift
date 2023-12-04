//
//  AnalyticsEvent.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-08.
//

enum AnalyticsEvent {
    
    // App lifecycle
    case appLaunch
    case appBackground
    case appInactive
    case appActive
    
    // Auth
    case loginSuccess
    case loginFailure
    case loginCancelled
    case logout
    case receivedAuthTokensFromPhone
    
    // Buttons
    case tappedSystemPlaylist
    case tappedUserPlaylist
    case tappedUser
    case tappedFollowUser
    case tappedTrack
    case tappedPlayAll
    case tappedShuffle
    case tappedLikeTrack
    case tappedLikePlaylist
    case tappedPlayerOptions
    
    case tappedTogglePlayback
    case tappedSkipToNextTrack
    case tappedSkipToPreviousTrack
    
    // API
    case tooManyRequests
    
    // Misc
    case loadLibrarySuccess
    case search(type: String)
}

extension AnalyticsEvent {
    var name: String {
        "\(self)"
    }
    
    var metadata: [String : String]? {
        switch self {
        case .search(let type): [
            "searchType" : type
        ]
        default: nil
        }
    }
}
