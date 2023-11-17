//
//  Int.swift
//  SC Demo
//
//  Created by Ryan Forsyth on 2023-08-12.
//

import Foundation

public extension Int {
    var timeStringFromSeconds: String {
        let minutes = String(format: "%02d", ((self % 3600) / 60))
        let seconds = String(format: "%02d", ((self % 3600) % 60))
        var result = minutes + ":" + seconds
        if self >= 3600 {
            let hours = String(format: "%02d", (self / 3600))
            result = hours + ":" + result
        }
        return result
    }
    
    var hoursAndMinutesStringFromSeconds: String {
        let minutesInt = (self % 3600) / 60
        
        let formattedMinutes = String(localized: "%02d mins", defaultValue: "\(minutesInt)mins")
        if self > 3600 {
            let hours = String(format: "%.1f", Double(self) / 3600.0)
            let formattedHours = String(localized: "\(hours)hrs")
            return formattedHours
        }
        return formattedMinutes
    }
    
    var formattedIfOver1000: String {
        if self < 1_000 { // Don't format
            return "\(self)"
        }
        if self < 1_000_000 {
            return String(format: "%.0fk", Double(self) / Double(1_000))
        }
        return String(format: "%.1fM", Double(self) / Double(1_000_000))
    }
}
