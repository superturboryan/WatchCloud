//
//  SpinAnimation.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-09-03.
//

import SwiftUI

struct SpinAnimation: ViewModifier {
    
    var duration: Double = 0.9
    var delay: Double = 0.4
    var autoreverses: Bool = false
    
    var animation: Animation {
        .easeInOut(duration: duration)
        .delay(delay)
        .repeatForever(autoreverses: autoreverses)
    }
    
    @State private var rotationDegrees: Double = 0.0
    
    func body(content: Content) -> some View {
        content.rotationEffect(.degrees(rotationDegrees))
            .onAppear { withAnimation(animation) {
                rotationDegrees = 360.0
            }
        }
    }
}

extension View {
    // TODO: add property parameters?
    func spinAnimation(_ enabled: Bool = true) -> some View {
        enabled ? AnyView(modifier(SpinAnimation())) : AnyView(self)
    }
}

struct SpinAnimation_Previews: PreviewProvider {
    static var previews: some View {
        Image(systemName: "arrow.down.circle")
            .resizable()
            .scaledToFit()
            .foregroundColor(.green)
            .frame(width: 100, height: 100)
            .spinAnimation()
    }
}
