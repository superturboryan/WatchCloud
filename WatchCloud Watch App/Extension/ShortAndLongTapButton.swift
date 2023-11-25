//
//  ShortAndLongTapButton.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-11-25.
//

import SwiftUI

/// SwiftUI Button that can recognize "short" and long tap gestures
///
/// - Parameters:
///    - shortTapGesture:action to perform when regular tap occurs.
///    - longTapBegan: action to perform when long tap begins.
///    - longTapEnded: (optional) action to perform when long tap ends.
///    - minimumLongTapDuration: minimum duration (in seconds) for long tap gesture to be recognized. **Defaults to 0.3**.
///    - label: The view to display on the button.
///
/// - Remark: After simultaneous `LongPressGesture` ends, the Button's other `TapGesture` gets fired as well.
///
struct ShortAndLongTapButton<Label: View>: View {
    
    @State var isLongTap = false
    
    var shortTapGesture: () -> Void
    var longTapBegan: () -> Void
    var longTapEnded: (() -> Void)?
    var minimumLongTapDuration = 0.3
    var label: () -> Label
    
    var body: some View {
        Button {
            if isLongTap {
                isLongTap = false
                longTapEnded?()
            } else {
                shortTapGesture()
            }
        } label: {
            label()
        }.simultaneousGesture(LongPressGesture(minimumDuration: minimumLongTapDuration).onEnded { _ in
            isLongTap = true
            longTapBegan()
        })
    }
}

#Preview {
    ShortAndLongTapButton(
        shortTapGesture: { print("Short tap") },
        longTapBegan: { print("Long tap start") },
        longTapEnded: { print("Long tap end") },
        label: { Text("Tap me")}
    )
}
