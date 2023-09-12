//
//  Progress.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-09-01.
//

import Foundation

extension Progress {
    static func with(_ percentComplete: Double) -> Progress {
        let progress = Progress(totalUnitCount: 1000)
        let pending = Int64(UInt64(exactly: 1000 * percentComplete)!)
        progress.becomeCurrent(withPendingUnitCount: pending)
        return progress
    }
}
