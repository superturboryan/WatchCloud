//
//  LinearGradientProgressViewStyle.swift
//  SC Watch Watch App
//
//  Created by Ryan Forsyth on 2023-09-07.
//
// Inspired by https://gist.github.com/akardas16/ffc94f391efde65c1ef1762bb472a8ec

import SwiftUI

struct LinearGradientProgressViewStyle<Fill: ShapeStyle, Background: ShapeStyle>: ProgressViewStyle {
    private let fill: Fill
    private let background: Background
    private let cornerRadius: CGFloat
    private let height: CGFloat
    private let animation: Animation
    init(
        fill: Fill,
        background: Background = Color.gray.opacity(0.5),
        cornerRadius: CGFloat = 4,
        height: CGFloat,
        animation: Animation = .default
    ) {
        self.fill = fill
        self.background = background
        self.cornerRadius = height / 2
        self.height = height
        self.animation = animation
    }
    
    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0
        VStack {
            ZStack(alignment: .topLeading) {
                GeometryReader { geo in
                    Rectangle().fill(background)
                        .overlay(
                            Capsule(style: .circular)
                                .fill(fill)
                                .frame(maxWidth: geo.size.width * CGFloat(fractionCompleted))
                                .animation(animation, value: fractionCompleted),
                            alignment: .leading
                        )
                }
            }
            .frame(height: height)
            .cornerRadius(cornerRadius)
        }
    }
}
