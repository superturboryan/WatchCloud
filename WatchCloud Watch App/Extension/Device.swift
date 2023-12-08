//
//  Device.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-05.
//

import WatchKit

enum Device {
    static let screenSize: CGSize = WKInterfaceDevice.current().screenBounds.size
}
