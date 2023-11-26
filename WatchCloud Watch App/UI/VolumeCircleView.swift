//
//  VolumeCircleView.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-09-14.
//

import SwiftUI

struct VolumeCircleView: View {
    
    @Binding var progress: Float
    var lineWidth: CGFloat
    
    var body: some View {
        ZStack(alignment: .center) {
            Circle().stroke(
                Color.scOrange.opacity(0.5),
                lineWidth: lineWidth
            )
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundStyle(LinearGradient.scOrange(.vertical, reversed: true))
                .animation(.default, value: progress)
                .rotationEffect(.degrees(-90))
            Image(systemName: "speaker.wave.3.fill", variableValue: Double(progress))
                .resizable()
                .scaledToFit()
                .padding(10)
                .foregroundStyle(LinearGradient.scOrange(.horizontal))
        }
    }
}

#Preview {
    StatefulPreviewWrapper(Float(1)) { progress in
        VStack(spacing: 20) {
            VolumeCircleView(progress: progress, lineWidth: 4)
                .frame(width: 50, height: 50)
            
            Slider(value: progress, in: 0 ... 1.0, step: 0.33333)
        }
    }
}

