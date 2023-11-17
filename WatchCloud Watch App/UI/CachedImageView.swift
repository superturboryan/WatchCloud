//
//  CachedImageView.swift
//  WatchCloud Watch App
//
//  Created by Ryan Forsyth on 2023-09-29.
//

import Nuke
import NukeUI
import SwiftUI

struct CachedImageView: View {
    
    // Dependencies
    let url: String?
    
    // Defaults
    var fallbackSystemImageName = "photo"
    var useCache = true
    var ratio: AspectRatio = .fit
    var animated = true
    var roundedCorners = true
    
    var body: some View {
        GeometryReader { geo in
            LazyImage(url: URL(string: url ?? "")) { state in
                ZStack {
                    if let image = state.image {
                        image.resizable()
                            .aspectRatio(contentMode: ratio == .fit ? .fit : .fill)
                            .animation(.default, value: image)
                    } else if state.error != nil {
                        Image(systemName: fallbackSystemImageName).resizable()
                            .aspectRatio(contentMode: ratio == .fit ? .fit : .fill)
                    } else {
                        ProgressView()
                    }
                }
                .transition(.opacity)
                .animation(.default, value: state.image)
                .fullWidthAndHeight()
                .clipShape(RoundedRectangle(cornerRadius: roundedCorners ? geo.size.width / 6 : 0))
            }
            .pipeline(useCache ? ImagePipeline(configuration: .withDataCache) : ImagePipeline.shared)
        }
    }
}

extension CachedImageView {
    enum AspectRatio { case fit, fill }
}

@available(watchOS 10, *)
#Preview(traits: .sizeThatFitsLayout){
    CachedImageView(url: "https://i1.sndcdn.com/artworks-P5t8zt92gBJyn3Ng-9YMhCg-t500x500.jpg")
        .frame(width: 100, height: 100)
}
