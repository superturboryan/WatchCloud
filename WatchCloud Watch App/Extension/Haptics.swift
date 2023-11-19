//
//  Haptic.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-09-06.
//

import WatchKit

struct Haptics {
    private init() {}
    private static let device = WKInterfaceDevice.current()
    static func click() { device.play(.click) }
    static func notification() { device.play(.notification) }
}
