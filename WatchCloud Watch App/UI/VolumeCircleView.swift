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
        ZStack {
            Circle().stroke(
                Color.scOrange.opacity(0.5),
                lineWidth: lineWidth
            )
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundStyle(LinearGradient.scOrange(.vertical, reversed: true))
                .rotationEffect(.degrees(-90))
                .animation(.default, value: progress)
            VStack {
                Image(systemName: "speaker.wave.2.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .foregroundStyle(LinearGradient.scOrange(.horizontal))
            }
        }
    }
}

struct VolumeCircleView_Previews: PreviewProvider {
    @State static var progress: Float = 0.9
    static var previews: some View {
        VolumeCircleView(progress: $progress, lineWidth: 6)
            .frame(width: 50.0, height: 50.0)
    }
}
