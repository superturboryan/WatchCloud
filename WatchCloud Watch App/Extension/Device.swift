//
//  Device.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-10-05.
//

import WatchKit

struct Device {
    private init() {}
    
    static let screenSize: CGSize = WKInterfaceDevice.current().screenBounds.size
}
