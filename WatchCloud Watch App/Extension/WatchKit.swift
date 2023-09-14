//
//  WatchKit.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-09-14.
//

#if os(watchOS)

import SwiftUI

/// Embed this view in a view's hierarchy to control watch's volume via digital crown
///
/// Apply `.opacity(0)` to hide the resulting view, then listen to the system's volume via an observer/publisher and update your own view
/// accordingly.
///
/// ```swift
/// volumeObserver = AVAudioSession.sharedInstance().observe(\.outputVolume) { session, _ in
///     print("System volume: \(session.outputVolume)")
/// }
/// ```
struct VolumeView: WKInterfaceObjectRepresentable {
    typealias WKInterfaceObjectType = WKInterfaceVolumeControl

    func makeWKInterfaceObject(context: Self.Context) -> WKInterfaceVolumeControl {
        let view = WKInterfaceVolumeControl(origin: .local)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak view] timer in
            if let view = view {
                view.focus()
            } else {
                timer.invalidate()
            }
        }
        DispatchQueue.main.async {
            view.focus()
        }
        return view
    }
    func updateWKInterfaceObject(_ wkInterfaceObject: WKInterfaceVolumeControl, context: WKInterfaceObjectRepresentableContext<VolumeView>) { }
}

#endif
