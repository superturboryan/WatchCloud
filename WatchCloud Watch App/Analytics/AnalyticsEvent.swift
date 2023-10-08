//
//  AnalyticsEvent.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-08.
//

enum AnalyticsEvent {
    
    // Auth
    case loginSuccess
    case loginFailure
    case loginCancelled
    case logout
    
    // Buttons
    case tappedPlaylist
    case tappedTrack
    case tappedLikeTrack
    case tappedLikePlaylist
    case tappedPlayerOptions
    
    // Critical
    case tooManyRequests
    
    // Misc
    case search(type: String)
}

extension AnalyticsEvent {
    var name: String {
        "\(self)"
    }
    
    var metadata: [String : String]? {
        switch self {
        case .search(let type): return [
            "searchType" : type
        ]
        default: return nil
        }
    }
}
